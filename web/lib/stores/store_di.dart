import 'dart:async';

import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/preferences.dart';
import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/shared_preference_helper.dart';
import 'package:brew_kettle_dashboard/stores/device_configuration/device_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/device_snapshot/device_snapshot_store.dart';
import 'package:brew_kettle_dashboard/stores/locale/locale_store.dart';
import 'package:brew_kettle_dashboard/stores/network_scanner/network_scanner_store.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/stores/theme/theme_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreModule {
  static Future<void> inject(GetIt getIt) async {
    Repository repository = Repository(SharedPreferenceHelper(
      await SharedPreferencesWithCache.create(
        cacheOptions: SharedPreferencesWithCacheOptions(
          allowList: PreferenceKey.allowList,
        ),
      ),
    ));

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

    getIt.registerSingleton<HeaterControllerStateStore>(
      HeaterControllerStateStore(
        webSocketConnectionStore: webSocketConnectionStore,
      ),
    );

    getIt.registerSingleton<NetworkScannerStore>(NetworkScannerStore());
    getIt.registerSingleton<LocaleStore>(LocaleStore(repository));
    getIt.registerSingleton<ThemeStore>(ThemeStore(repository));
  }
}
