import 'dart:convert';

import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/device_configuration/device_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/device_snapshot/device_snapshot_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/screens/device_info/greyscale_image.dart';
import 'package:brew_kettle_dashboard/utils/pixels.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class DeviceInfoScreen extends StatelessWidget {
  final WebSocketConnectionStore _wsConnectionStore =
      getIt<WebSocketConnectionStore>();

  final DeviceConfigurationStore _deviceConfigurationStore =
      getIt<DeviceConfigurationStore>();

  final DeviceSnapshotStore _deviceSnapshotStore = getIt<DeviceSnapshotStore>();

  DeviceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(),
            child: const Text('Send'),
            onPressed: () {
              _wsConnectionStore.message("Hello There");
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(),
            child: const Text('Send'),
            onPressed: () {
              _deviceConfigurationStore.request();
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(),
            child: const Text('Send snapshot request'),
            onPressed: () {
              _deviceSnapshotStore.request();
            },
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(),
            child: const Text('Show image'),
            onPressed: () {},
          ),
          Observer(builder: (context) {
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
          })
        ],
      ),
    );
  }
}
