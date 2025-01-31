import 'dart:async';

import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  final SharedPreferencesWithCache _sharedPreference;

  SharedPreferenceHelper(this._sharedPreference);

  // ===============
  // Theme
  // ===============
  String? get theme {
    return _sharedPreference.getString(PreferenceKey.theme.key);
  }

  Future changeTheme(String value) {
    return _sharedPreference.setString(PreferenceKey.theme.key, value);
  }

  // ===============
  // Language:
  // ===============
  String? get currentLocale {
    return _sharedPreference.getString(PreferenceKey.currentLocale.key);
  }

  Future changeLanguage(String language) {
    return _sharedPreference.setString(
      PreferenceKey.currentLocale.key,
      language,
    );
  }
}
