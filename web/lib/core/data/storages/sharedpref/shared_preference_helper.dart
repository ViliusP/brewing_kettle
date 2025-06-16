import 'dart:async';

import 'package:brew_kettle_dashboard/core/data/models/common/temperature_scale.dart';
import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/preferences.dart';
import 'package:brew_kettle_dashboard/utils/enum_extensions.dart';
import 'package:flutter/services.dart';
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

  // =====================================
  // Fake Browser Address Bar Position:
  // =====================================
  Offset get fakeBrowserAddressBarPosition {
    final double x = _sharedPreference.getDouble(PreferenceKey.fakeUrlBrowserPositionX.key) ?? 0;
    final double y = _sharedPreference.getDouble(PreferenceKey.fakeUrlBrowserPositionY.key) ?? 0;
    return Offset(x, y);
  }

  Future setFakeBrowserAddressBarPosition(Offset value) {
    return Future.wait([
      _sharedPreference.setDouble(PreferenceKey.fakeUrlBrowserPositionX.key, value.dx),
      _sharedPreference.setDouble(PreferenceKey.fakeUrlBrowserPositionY.key, value.dy),
    ]);
  }

  // ===============
  // Theme
  // ===============
  /// Gets the temperature scale from shared preferences.
  /// If the value is not set, it will return null.
  /// If the value is set, it will return the corresponding [TemperatureScale] enum value.
  TemperatureScale? get temperatureScale {
    final String? rawTemperatureScale = _sharedPreference.getString(
      PreferenceKey.temperatureScale.key,
    );

    if (rawTemperatureScale == null) {
      return null;
    }

    return TemperatureScale.values.byNameSafe(rawTemperatureScale);
  }

  /// Sets the temperature scale in shared preferences.
  ///
  /// Returns a [Future] that completes when the value is set.
  Future setTemperatureScale(TemperatureScale value) {
    return _sharedPreference.setString(PreferenceKey.temperatureScale.key, value.name);
  }
}
