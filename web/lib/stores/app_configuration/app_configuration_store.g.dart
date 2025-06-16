// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_configuration_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppConfigurationStore on _AppConfigurationStore, Store {
  Computed<TemperatureScale>? _$temperatureScaleComputed;

  @override
  TemperatureScale get temperatureScale =>
      (_$temperatureScaleComputed ??= Computed<TemperatureScale>(
            () => super.temperatureScale,
            name: '_AppConfigurationStore.temperatureScale',
          ))
          .value;
  Computed<bool>? _$isAdvancedModeComputed;

  @override
  bool get isAdvancedMode =>
      (_$isAdvancedModeComputed ??= Computed<bool>(
            () => super.isAdvancedMode,
            name: '_AppConfigurationStore.isAdvancedMode',
          ))
          .value;
  Computed<bool>? _$fakeBrowserBarEnabledComputed;

  @override
  bool get fakeBrowserBarEnabled =>
      (_$fakeBrowserBarEnabledComputed ??= Computed<bool>(
            () => super.fakeBrowserBarEnabled,
            name: '_AppConfigurationStore.fakeBrowserBarEnabled',
          ))
          .value;
  Computed<bool>? _$globalPointerPositionMetricEnabledComputed;

  @override
  bool get globalPointerPositionMetricEnabled =>
      (_$globalPointerPositionMetricEnabledComputed ??= Computed<bool>(
            () => super.globalPointerPositionMetricEnabled,
            name: '_AppConfigurationStore.globalPointerPositionMetricEnabled',
          ))
          .value;

  late final _$_temperatureScaleAtom = Atom(
    name: '_AppConfigurationStore._temperatureScale',
    context: context,
  );

  @override
  TemperatureScale get _temperatureScale {
    _$_temperatureScaleAtom.reportRead();
    return super._temperatureScale;
  }

  @override
  set _temperatureScale(TemperatureScale value) {
    _$_temperatureScaleAtom.reportWrite(value, super._temperatureScale, () {
      super._temperatureScale = value;
    });
  }

  late final _$_isAdvancedModeAtom = Atom(
    name: '_AppConfigurationStore._isAdvancedMode',
    context: context,
  );

  @override
  bool get _isAdvancedMode {
    _$_isAdvancedModeAtom.reportRead();
    return super._isAdvancedMode;
  }

  @override
  set _isAdvancedMode(bool value) {
    _$_isAdvancedModeAtom.reportWrite(value, super._isAdvancedMode, () {
      super._isAdvancedMode = value;
    });
  }

  late final _$_fakeBrowserBarEnabledAtom = Atom(
    name: '_AppConfigurationStore._fakeBrowserBarEnabled',
    context: context,
  );

  @override
  bool get _fakeBrowserBarEnabled {
    _$_fakeBrowserBarEnabledAtom.reportRead();
    return super._fakeBrowserBarEnabled;
  }

  @override
  set _fakeBrowserBarEnabled(bool value) {
    _$_fakeBrowserBarEnabledAtom.reportWrite(
      value,
      super._fakeBrowserBarEnabled,
      () {
        super._fakeBrowserBarEnabled = value;
      },
    );
  }

  late final _$_globalPointerPositionMetricEnabledAtom = Atom(
    name: '_AppConfigurationStore._globalPointerPositionMetricEnabled',
    context: context,
  );

  @override
  bool get _globalPointerPositionMetricEnabled {
    _$_globalPointerPositionMetricEnabledAtom.reportRead();
    return super._globalPointerPositionMetricEnabled;
  }

  @override
  set _globalPointerPositionMetricEnabled(bool value) {
    _$_globalPointerPositionMetricEnabledAtom.reportWrite(
      value,
      super._globalPointerPositionMetricEnabled,
      () {
        super._globalPointerPositionMetricEnabled = value;
      },
    );
  }

  late final _$_AppConfigurationStoreActionController = ActionController(
    name: '_AppConfigurationStore',
    context: context,
  );

  @override
  void setAdvancedMode(bool value) {
    final _$actionInfo = _$_AppConfigurationStoreActionController.startAction(
      name: '_AppConfigurationStore.setAdvancedMode',
    );
    try {
      return super.setAdvancedMode(value);
    } finally {
      _$_AppConfigurationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void toggleAdvancedMode() {
    final _$actionInfo = _$_AppConfigurationStoreActionController.startAction(
      name: '_AppConfigurationStore.toggleAdvancedMode',
    );
    try {
      return super.toggleAdvancedMode();
    } finally {
      _$_AppConfigurationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setFakeBrowserBar(bool value) {
    final _$actionInfo = _$_AppConfigurationStoreActionController.startAction(
      name: '_AppConfigurationStore.setFakeBrowserBar',
    );
    try {
      return super.setFakeBrowserBar(value);
    } finally {
      _$_AppConfigurationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setGlobalPointerPositionMetric(bool value) {
    final _$actionInfo = _$_AppConfigurationStoreActionController.startAction(
      name: '_AppConfigurationStore.setGlobalPointerPositionMetric',
    );
    try {
      return super.setGlobalPointerPositionMetric(value);
    } finally {
      _$_AppConfigurationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setTemperatureScale(TemperatureScale scale) {
    final _$actionInfo = _$_AppConfigurationStoreActionController.startAction(
      name: '_AppConfigurationStore.setTemperatureScale',
    );
    try {
      return super.setTemperatureScale(scale);
    } finally {
      _$_AppConfigurationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
temperatureScale: ${temperatureScale},
isAdvancedMode: ${isAdvancedMode},
fakeBrowserBarEnabled: ${fakeBrowserBarEnabled},
globalPointerPositionMetricEnabled: ${globalPointerPositionMetricEnabled}
    ''';
  }
}
