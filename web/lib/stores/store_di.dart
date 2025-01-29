import 'dart:async';

import 'package:brew_kettle_dashboard/stores/device_configuration/device_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/device_snapshot/device_snapshot_store.dart';
import 'package:brew_kettle_dashboard/stores/network_scanner/network_scanner_store.dart';
import 'package:brew_kettle_dashboard/stores/current_temperature/current_temperature_store.dart';
import 'package:brew_kettle_dashboard/stores/target_temperature/target_temperature_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:get_it/get_it.dart';

class StoreModule {
  static Future<void> inject(GetIt getIt) async {
    final webSocketConnectionStore = WebSocketConnectionStore();

    getIt.registerSingleton<WebSocketConnectionStore>(webSocketConnectionStore);
    getIt.registerSingleton<DeviceConfigurationStore>(
      DeviceConfigurationStore(
        webSocketConnectionStore: webSocketConnectionStore,
      ),
    );

    getIt.registerSingleton<DeviceSnapshotStore>(
      DeviceSnapshotStore(webSocketConnectionStore: webSocketConnectionStore),
    );

    getIt.registerSingleton<CurrentTemperatureStore>(
      CurrentTemperatureStore(
        webSocketConnectionStore: webSocketConnectionStore,
      ),
    );

    getIt.registerSingleton<TargetTemperatureStore>(
      TargetTemperatureStore(
        webSocketConnectionStore: webSocketConnectionStore,
      ),
    );

    getIt.registerSingleton<NetworkScannerStore>(NetworkScannerStore());
  }
}
