import 'package:brew_kettle_dashboard/core/data/repository/system_info_repository.dart';
import 'package:brew_kettle_dashboard/core/data/repository/websocket_connection_repository.dart';
import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/shared_preference_helper.dart';

class Repository {
  const Repository({
    required SharedPreferenceHelper sharedPreferences,
    required SystemInfoRepository systemInfo,
    required WebSocketConnectionRepository webSocketConnection,
  }) : _sharedPreferences = sharedPreferences,
       _webSocketConnection = webSocketConnection,
       _systemInfo = systemInfo;

  final SystemInfoRepository _systemInfo;
  SystemInfoRepository get systemInfo => _systemInfo;

  final SharedPreferenceHelper _sharedPreferences;
  SharedPreferenceHelper get sharedPreferences => _sharedPreferences;

  final WebSocketConnectionRepository _webSocketConnection;
  WebSocketConnectionRepository get webSocketConnection => _webSocketConnection;
}
