import 'dart:async';

import 'package:brew_kettle_dashboard/core/data/network/kettle_api/pid_api.dart';
import 'package:brew_kettle_dashboard/core/data/network/kettle_api/system_info_api.dart';
import 'package:brew_kettle_dashboard/core/data/network/kettle_client.dart';
import 'package:brew_kettle_dashboard/core/data/repository/pid_repository.dart';
import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:brew_kettle_dashboard/core/data/repository/system_info_repository.dart';
import 'package:brew_kettle_dashboard/core/data/repository/websocket_connection_repository.dart';
import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/preferences.dart';
import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/shared_preference_helper.dart';
import 'package:brew_kettle_dashboard/stores/device_info/system_info_store.dart';
import 'package:brew_kettle_dashboard/stores/device_snapshot/device_snapshot_store.dart';
import 'package:brew_kettle_dashboard/stores/exception/exception_store.dart';
import 'package:brew_kettle_dashboard/stores/locale/locale_store.dart';
import 'package:brew_kettle_dashboard/stores/network_scanner/network_scanner_store.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/stores/pid/pid_store.dart';
import 'package:brew_kettle_dashboard/stores/theme/theme_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreModule {
  static Future<void> inject(GetIt getIt) async {
    KettleClient kettleClient = KettleClient();

    Repository repository = Repository(
      systemInfo: SystemInfoRepository(SystemInfoApi(client: kettleClient)),
      pidRepository: PidRepository(PidApi(client: kettleClient)),

      webSocketConnection: WebSocketConnectionRepository(kettleClient),
      sharedPreferences: SharedPreferenceHelper(
        await SharedPreferencesWithCache.create(
          cacheOptions: SharedPreferencesWithCacheOptions(allowList: PreferenceKey.allowList),
        ),
      ),
    );

    final ExceptionStore exceptionStore = ExceptionStore();
    getIt.registerSingleton<ExceptionStore>(exceptionStore);

    final webSocketConnectionStore = WebSocketConnectionStore(
      repository: repository,
      exceptionStore: exceptionStore,
    );

    getIt.registerSingleton<WebSocketConnectionStore>(webSocketConnectionStore);
    getIt.registerSingleton<SystemInfoStore>(
      SystemInfoStore(repository: repository, errorStore: exceptionStore),
    );

    getIt.registerSingleton<DeviceSnapshotStore>(
      DeviceSnapshotStore(webSocketConnectionStore: webSocketConnectionStore),
    );

    getIt.registerSingleton<HeaterControllerStateStore>(
      HeaterControllerStateStore(webSocketConnectionStore: webSocketConnectionStore),
    );
    getIt.registerSingleton<PidStore>(
      PidStore(
        webSocketConnectionStore: webSocketConnectionStore,
        repository: repository,
        exceptionStore: exceptionStore,
      ),
    );

    getIt.registerSingleton<NetworkScannerStore>(NetworkScannerStore());
    getIt.registerSingleton<LocaleStore>(LocaleStore(repository));
    getIt.registerSingleton<ThemeStore>(ThemeStore(repository));
  }
}
