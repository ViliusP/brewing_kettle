import 'dart:convert';

import 'package:brew_kettle_dashboard/core/data/models/api/device_configuration.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/device_info/system_info_store.dart';
import 'package:brew_kettle_dashboard/stores/device_snapshot/device_snapshot_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/screens/devices/greyscale_image.dart';
import 'package:brew_kettle_dashboard/ui/screens/devices/message_logs_viewer.dart';
import 'package:brew_kettle_dashboard/utils/pixels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CommunicatorControllerInfoCard extends StatefulWidget {
  const CommunicatorControllerInfoCard({super.key});

  @override
  State<CommunicatorControllerInfoCard> createState() => _CommunicatorControllerInfoCardState();
}

class _CommunicatorControllerInfoCardState extends State<CommunicatorControllerInfoCard> {
  final SystemInfoStore _systemInfoStore = getIt<SystemInfoStore>();

  final DeviceSnapshotStore _deviceSnapshotStore = getIt<DeviceSnapshotStore>();

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = TextTheme.of(context);
    final DeviceInfo? communicatorInfo = _systemInfoStore.info?.communicator;
    final DeviceHardwareInfo? hardware = communicatorInfo?.hardware;
    final DeviceSoftwareInfo? software = communicatorInfo?.software;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(localizations.devicesCommunicationController, style: textTheme.titleLarge),
        SelectableRegion(
          focusNode: _focusNode,
          selectionControls: materialTextSelectionControls,
          child: Column(
            children: [
              Text("${hardware?.chip}", style: textTheme.bodyLarge),
              Padding(padding: EdgeInsets.symmetric(vertical: 2)),
              Text(
                "${localizations.generalVersion} ${software?.version}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "${localizations.devicesSecureVersion} ${software?.secureVersion}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "${localizations.devicesCompileTime} ${software?.compileTime}",
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Divider(),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(localizations.devicesScreenshot, style: textTheme.titleLarge),
            Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
            SizedBox.square(
              dimension: 28,
              child: IconButton.outlined(
                onPressed: () => _deviceSnapshotStore.request(),
                icon: Icon(MdiIcons.refresh),
                alignment: Alignment.center,
                padding: EdgeInsets.all(0),
                iconSize: 18,
                tooltip: localizations.devicesScreenshotRefreshTooltip,
              ),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        _ControllerScreen(),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Divider(),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Text(localizations.devicesCommunicationLog, style: textTheme.titleLarge),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),

        _MessagesLogPreview(),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

class _MessagesLogPreview extends StatelessWidget {
  _MessagesLogPreview();

  final WebSocketConnectionStore _wsConnectionStore = getIt<WebSocketConnectionStore>();

  Future<void> _dialogBuilder(BuildContext context) => showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog.fullscreen(child: MessageLogsViewer(data: _wsConnectionStore.logs));
    },
  );

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = TextTheme.of(context);
    final ColorScheme colorScheme = ColorScheme.of(context);
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    TextStyle defaultTextStyle =
        textTheme.bodySmall ??
        TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface);

    double iconSize = (defaultTextStyle.fontSize?.toInt() ?? 17) + 3;

    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Observer(
              builder: (context) {
                return JsonView.string(
                  _wsConnectionStore.logs,
                  theme: JsonViewTheme(
                    viewType: JsonViewType.base,
                    openIcon: Icon(MdiIcons.plus, size: iconSize),
                    closeIcon: Icon(MdiIcons.close, size: iconSize),
                    separator: Text(": ", style: defaultTextStyle),
                    backgroundColor: colorScheme.surface,
                    defaultTextStyle: defaultTextStyle,
                    keyStyle: TextStyle(color: colorScheme.primary),
                    boolStyle: TextStyle(color: colorScheme.inverseSurface),
                    intStyle: TextStyle(color: colorScheme.inverseSurface),
                    stringStyle: TextStyle(color: colorScheme.inverseSurface),
                    doubleStyle: TextStyle(color: colorScheme.inverseSurface),
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Observer(
                builder: (context) {
                  if (_wsConnectionStore.messages.length <= 3) {
                    return SizedBox.shrink();
                  }
                  return IconButton.outlined(
                    onPressed: () => _dialogBuilder(context),
                    icon: Icon(MdiIcons.scriptTextOutline),
                    tooltip: localizations.devicesShowMoreLogTooltip,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControllerScreen extends StatefulWidget {
  const _ControllerScreen();

  @override
  State<_ControllerScreen> createState() => _ControllerScreenState();
}

class _ControllerScreenState extends State<_ControllerScreen> {
  final DeviceSnapshotStore _deviceSnapshotStore = getIt<DeviceSnapshotStore>();

  @override
  void initState() {
    _deviceSnapshotStore.request();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 128, minHeight: 64),
          child: Observer(
            builder: (context) {
              Widget child;
              if (_deviceSnapshotStore.snapshot != null) {
                Uint8List imageBuffer = base64Decode(_deviceSnapshotStore.snapshot!.buffer!);
                child = GrayscaleImage(
                  key: ValueKey("image"),
                  buffer: imageBuffer.rgb888ToRgba8888(
                    _deviceSnapshotStore.snapshot!.width!,
                    _deviceSnapshotStore.snapshot!.height!,
                  ),
                  // Number of pixels per row
                  width: _deviceSnapshotStore.snapshot!.width!,
                  // Number of rows
                  height: _deviceSnapshotStore.snapshot!.height!,
                );
              } else {
                child = DecoratedBox(
                  key: ValueKey("placeholder"),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                );
              }

              return SizedBox(
                width: 128,
                height: 64,
                child: AnimatedSwitcher(duration: Durations.short2, child: child),
              );
            },
          ),
        ),
      ],
    );
  }
}
