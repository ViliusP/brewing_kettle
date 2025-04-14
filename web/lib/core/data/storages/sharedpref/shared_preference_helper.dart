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

  Future setTheme(String value) {
    return _sharedPreference.setString(PreferenceKey.theme.key, value);
  }

  // ===============
  // Language:
  // ===============
  String? get locale {
    return _sharedPreference.getString(PreferenceKey.locale.key);
  }

  Future setLocale(String value) {
    return _sharedPreference.setString(PreferenceKey.locale.key, value);
  }

  // ===============
  // Advanced Mode:
  // ===============
  bool? get advancedMode {
    return _sharedPreference.getBool(PreferenceKey.advancedMode.key);
  }

  Future setAdvancedMode(bool value) {
    return _sharedPreference.setBool(PreferenceKey.advancedMode.key, value);
  }
}
