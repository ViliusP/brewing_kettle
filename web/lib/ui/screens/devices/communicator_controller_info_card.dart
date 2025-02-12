import 'dart:convert';

import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/device_info/devices_info_store.dart';
import 'package:brew_kettle_dashboard/stores/device_snapshot/device_snapshot_store.dart';
import 'package:brew_kettle_dashboard/ui/screens/devices/greyscale_image.dart';
import 'package:brew_kettle_dashboard/utils/pixels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CommnuicatorControllerInfoCard extends StatelessWidget {
  CommnuicatorControllerInfoCard({super.key});

  final DevicesInfoStore _deviceInfoStore = getIt<DevicesInfoStore>();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = TextTheme.of(context);
    DeviceInfo? device = _deviceInfoStore.controllers?.communicator;
    DeviceHardwareInfo? hardware = device?.hardware;
    DeviceSoftwareInfo? software = device?.software;

    return SelectableRegion(
      focusNode: _focusNode,
      selectionControls: materialTextSelectionControls,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(),
            onPressed: _deviceInfoStore.request,
            child: const Text('Send'),
          ),
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
          Divider(),
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
          Divider(),
          _ControllerScreen(),
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(),
          child: const Text('Send snapshot request'),
          onPressed: () {
            _deviceSnapshotStore.request();
          },
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
