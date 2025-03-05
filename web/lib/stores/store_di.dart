import 'dart:async';

import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:brew_kettle_dashboard/core/data/repository/websocket_connection_repository.dart';
import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/preferences.dart';
import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/shared_preference_helper.dart';
import 'package:brew_kettle_dashboard/stores/device_info/devices_info_store.dart';
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
    Repository repository = Repository(
      webSocketConnection: WebSocketConnectionRepository(),
      sharedPreferences: SharedPreferenceHelper(
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(allowList: PreferenceKey.allowList),
        ),
      ),
    );

    final ExceptionStore exceptionStore = ExceptionStore();
    getIt.registerSingleton<ExceptionStore>(exceptionStore);

    final webSocketConnectionStore = WebSocketConnectionStore(repository);

    getIt.registerSingleton<WebSocketConnectionStore>(webSocketConnectionStore);
    getIt.registerSingleton<DevicesInfoStore>(
      DevicesInfoStore(webSocketConnectionStore: webSocketConnectionStore),
    );

    getIt.registerSingleton<DeviceSnapshotStore>(
      DeviceSnapshotStore(webSocketConnectionStore: webSocketConnectionStore),
    );

    getIt.registerSingleton<HeaterControllerStateStore>(
      HeaterControllerStateStore(webSocketConnectionStore: webSocketConnectionStore),
    );

    getIt.registerSingleton<NetworkScannerStore>(NetworkScannerStore());
    getIt.registerSingleton<LocaleStore>(LocaleStore(repository));
    getIt.registerSingleton<ThemeStore>(ThemeStore(repository));
  }
}
