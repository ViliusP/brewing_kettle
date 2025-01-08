import 'dart:async';

import 'package:brew_kettle_dashboard/stores/network_scanner/network_scanner_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:get_it/get_it.dart';

class StoreModule {
  static Future<void> inject(GetIt getIt) async {
    getIt.registerSingleton<NetworkScannerStore>(NetworkScannerStore());
    getIt.registerSingleton<WebSocketConnectionStore>(
      WebSocketConnectionStore(),
    );
  }
}
