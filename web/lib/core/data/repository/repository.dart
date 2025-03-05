import 'package:brew_kettle_dashboard/core/data/repository/websocket_connection_repository.dart';
import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/shared_preference_helper.dart';

class Repository {
  const Repository({
    required SharedPreferenceHelper sharedPreferences,
    required WebSocketConnectionRepository webSocketConnection,
  }) : _sharedPreferences = sharedPreferences,
       _webSocketConnection = webSocketConnection,
  // Sub repos

  final SharedPreferenceHelper _sharedPrefsHelper;

  Repository(this._sharedPrefsHelper);

  SharedPreferenceHelper get sharedPreferences {
    return _sharedPrefsHelper;
  }

  final SharedPreferenceHelper _sharedPreferences;
  SharedPreferenceHelper get sharedPreferences => _sharedPreferences;

  final WebSocketConnectionRepository _webSocketConnection;
  WebSocketConnectionRepository get webSocketConnection => _webSocketConnection;
}
