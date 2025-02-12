import 'dart:convert';

import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/device_info/devices_info_store.dart';
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

class CommnuicatorControllerInfoCard extends StatelessWidget {
  CommnuicatorControllerInfoCard({super.key});

  final DevicesInfoStore _deviceInfoStore = getIt<DevicesInfoStore>();

  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = TextTheme.of(context);
    DeviceInfo? device = _deviceInfoStore.controllers?.communicator;
    DeviceHardwareInfo? hardware = device?.hardware;
    DeviceSoftwareInfo? software = device?.software;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FilledButton.tonal(
          onPressed: _deviceInfoStore.request,
          child: const Text('Get devices info'),
        ),
        SelectableRegion(
          focusNode: _focusNode1,
          selectionControls: materialTextSelectionControls,
          child: Column(
            children: [
              Text(
                "Komunikacijos kontroleris",
                style: textTheme.titleLarge,
              ),
              Text(
                "chip ${hardware?.chip}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "cores ${hardware?.cores}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "Features ${hardware?.features}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "flash size ${hardware?.flash.size} (bytes)",
                style: textTheme.bodyMedium,
              ),
              Text(
                "flash type ${hardware?.flash.type} ",
                style: textTheme.bodyMedium,
              ),
              Text(
                "Silicon revision ${hardware?.siliconRevision}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "Heap size ${hardware?.minimumHeapSize} (bytes)",
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Divider(),
        SelectableRegion(
          focusNode: _focusNode2,
          selectionControls: materialTextSelectionControls,
          child: Column(
            children: [
              Text(
                "Project name ${software?.projectName}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "Version ${software?.version}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "Secure version ${software?.secureVersion}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "IDF version ${software?.idfVersion}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "Compile time ${software?.compileTime}",
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Divider(),
        Text(
          "Ekranas",
          style: textTheme.titleLarge,
        ),
        _ControllerScreen(),
        Divider(),
        Text(
          "Komunikacijos išrašas",
          style: textTheme.titleLarge,
        ),
        _MessagesLogPreview(),
      ],
    );
  }
}

class _MessagesLogPreview extends StatelessWidget {
  _MessagesLogPreview();

  final WebSocketConnectionStore _wsConnectionStore =
      getIt<WebSocketConnectionStore>();

  Future<void> _dialogBuilder(BuildContext context) => showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return Dialog.fullscreen(
            child: MessageLogsViewer(
              data: _wsConnectionStore.logs,
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = TextTheme.of(context);
    ColorScheme colorScheme = ColorScheme.of(context);

    TextStyle defaultTextStyle = textTheme.bodySmall ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        );

    double iconSize = (defaultTextStyle.fontSize?.toInt() ?? 17) + 3;

    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Observer(builder: (context) {
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
            }),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Observer(builder: (context) {
                if (_wsConnectionStore.messages.length <= 3) {
                  return SizedBox.shrink();
                }
                return IconButton.outlined(
                  onPressed: () => _dialogBuilder(context),
                  icon: Icon(MdiIcons.scriptTextOutline),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControllerScreen extends StatelessWidget {
  final DeviceSnapshotStore _deviceSnapshotStore = getIt<DeviceSnapshotStore>();

  _ControllerScreen();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton.tonal(
          child: const Text('Send snapshot request'),
          onPressed: () => _deviceSnapshotStore.request(),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 128, minHeight: 64),
          child: Observer(builder: (context) {
            if (_deviceSnapshotStore.snapshot != null) {
              Uint8List imageBuffer = base64Decode(
                _deviceSnapshotStore.snapshot!.buffer!,
              );
              return GrayscaleImage(
                buffer: imageBuffer.rgb888ToRgba8888(
                  _deviceSnapshotStore.snapshot!.width!,
                  _deviceSnapshotStore.snapshot!.height!,
                ),
                // Number of pixels per row
                width: _deviceSnapshotStore.snapshot!.width!,
                // Number of rows
                height: _deviceSnapshotStore.snapshot!.height!,
              );
            }
            return SizedBox.shrink();
          }),
        ),
      ],
    );
  }
}
