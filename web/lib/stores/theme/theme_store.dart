import 'dart:ui';

import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:flutter/scheduler.dart';
import 'package:mobx/mobx.dart';

part 'theme_store.g.dart';

// ignore: library_private_types_in_public_api
class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store {
  final Repository _repository;

  _ThemeStore(Repository repository) : _repository = repository {
    _init();
  }

  // ===================
  // Store variables:
  // ===================
  @observable
  AppThemeMode _themeMode = AppThemeMode.system;

  @computed
  AppThemeMode get themeMode => _themeMode;

  @observable
  AppTheme _theme = AppDefaults.theme;

  @computed
  AppTheme get theme => _theme;

  // ==============
  // Actions:
  // ==============
  @action
  void changeThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    _repository.sharedPreferences.setTheme(mode.key);
    _theme = _byAppThemeMode(mode);
  }

  // ======================
  // General:
  // ======================
  void _init() {
    String? prefTheme = _repository.sharedPreferences.theme;
    _themeMode = AppThemeMode.values.firstWhere(
      (v) => v.key == prefTheme,
      orElse: () => AppThemeMode.system,
    );
    _theme = _byAppThemeMode(_themeMode);
  }

  static AppTheme _byAppThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return AppTheme.light;
      case AppThemeMode.dark:
        return AppTheme.dark;
      case AppThemeMode.system:
        var platformBrightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
        return switch (platformBrightness) {
          Brightness.light => AppTheme.light,
          Brightness.dark => AppTheme.dark,
        };
    }
  }

  void dispose() async {}
}
