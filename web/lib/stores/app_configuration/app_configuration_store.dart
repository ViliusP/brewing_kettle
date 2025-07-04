import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/core/data/models/common/temperature_scale.dart';
import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';

part 'app_configuration_store.g.dart';

// ignore: library_private_types_in_public_api
class AppConfigurationStore = _AppConfigurationStore with _$AppConfigurationStore;

abstract class _AppConfigurationStore with Store {
  final Repository _repository;

  _AppConfigurationStore(Repository repository) : _repository = repository {
    _init();
  }

  // ===================
  // Store variables:
  // ===================
  // ------- Temperature Scale -------
  @observable
  TemperatureScale _temperatureScale = AppDefaults.temperatureScale;

  @computed
  TemperatureScale get temperatureScale => _temperatureScale;

  // ------- Advanced Mode -------
  @observable
  bool _isAdvancedMode = AppDefaults.isAdvancedMode;

  @computed
  bool get isAdvancedMode => _isAdvancedMode;

  // ------- Fake Browser URL bar -------
  @observable
  bool _fakeBrowserBarEnabled = true;

  @computed
  bool get fakeBrowserBarEnabled => _fakeBrowserBarEnabled && isAdvancedMode;

  Offset _fakeBrowserAddressBarPosition = Offset.zero;

  Offset get fakeBrowserAddressBarPosition => _fakeBrowserAddressBarPosition;

  // ------- Metrics Box -------
  bool get metricsBoxEnabled => _globalPointerPositionMetricEnabled && isAdvancedMode;

  // +++++++ Global Pointer Position +++++++
  @observable
  bool _globalPointerPositionMetricEnabled = true;

  @computed
  bool get globalPointerPositionMetricEnabled => _globalPointerPositionMetricEnabled;

  // ==============
  // Actions:
  // ==============
  @action
  void setAdvancedMode(bool value) {
    _isAdvancedMode = value;
    _repository.sharedPreferences.setAdvancedMode(value);
  }

  @action
  void toggleAdvancedMode() {
    _isAdvancedMode = !_isAdvancedMode;
    _repository.sharedPreferences.setAdvancedMode(_isAdvancedMode);
  }

  void setFakeUrlBarPosition(Offset value) {
    _repository.sharedPreferences.setFakeBrowserAddressBarPosition(value);
  }

  @action
  void setFakeBrowserBar(bool value) {
    _fakeBrowserBarEnabled = value;
  }

  @action
  void setGlobalPointerPositionMetric(bool value) {
    _globalPointerPositionMetricEnabled = value;
  }

  /// Sets the temperature [scale] for the app.
  /// This will also save the scale to shared preferences.
  @action
  void setTemperatureScale(TemperatureScale scale) {
    _temperatureScale = scale;
    _repository.sharedPreferences.setTemperatureScale(scale);
  }

  // ======================
  // General:
  // ======================
  void _init() async {
    bool? prefsAdvancedMode = _repository.sharedPreferences.advancedMode;
    _fakeBrowserAddressBarPosition = _repository.sharedPreferences.fakeBrowserAddressBarPosition;
    if (prefsAdvancedMode != null) {
      _isAdvancedMode = prefsAdvancedMode;
    }

    final TemperatureScale? prefsTemperatureScale = _repository.sharedPreferences.temperatureScale;
    if (prefsTemperatureScale != null) {
      _temperatureScale = prefsTemperatureScale;
    }
  }

  void dispose() async {}
}
