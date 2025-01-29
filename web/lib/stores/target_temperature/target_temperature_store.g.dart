// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_temperature_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TargetTemperatureStore on _TargetTemperatureStore, Store {
  Computed<List<TimeseriesViewEntry>>? _$temperatureHistoryComputed;

  @override
  List<TimeseriesViewEntry> get temperatureHistory =>
      (_$temperatureHistoryComputed ??= Computed<List<TimeseriesViewEntry>>(
              () => super.temperatureHistory,
              name: '_TargetTemperatureStore.temperatureHistory'))
          .value;
  Computed<double?>? _$targetTemperatureComputed;

  @override
  double? get targetTemperature => (_$targetTemperatureComputed ??=
          Computed<double?>(() => super.targetTemperature,
              name: '_TargetTemperatureStore.targetTemperature'))
      .value;
  Computed<double?>? _$lastRequestedTemperatureComputed;

  @override
  double? get lastRequestedTemperature =>
      (_$lastRequestedTemperatureComputed ??= Computed<double?>(
              () => super.lastRequestedTemperature,
              name: '_TargetTemperatureStore.lastRequestedTemperature'))
          .value;

  late final _$_temperatureHistoryAtom = Atom(
      name: '_TargetTemperatureStore._temperatureHistory', context: context);

  @override
  ObservableList<TimeSeriesEntry> get _temperatureHistory {
    _$_temperatureHistoryAtom.reportRead();
    return super._temperatureHistory;
  }

  @override
  set _temperatureHistory(ObservableList<TimeSeriesEntry> value) {
    _$_temperatureHistoryAtom.reportWrite(value, super._temperatureHistory, () {
      super._temperatureHistory = value;
    });
  }

  late final _$_targetTemperatureAtom = Atom(
      name: '_TargetTemperatureStore._targetTemperature', context: context);

  @override
  double? get _targetTemperature {
    _$_targetTemperatureAtom.reportRead();
    return super._targetTemperature;
  }

  @override
  set _targetTemperature(double? value) {
    _$_targetTemperatureAtom.reportWrite(value, super._targetTemperature, () {
      super._targetTemperature = value;
    });
  }

  late final _$_lastRequestedTemperatureAtom = Atom(
      name: '_TargetTemperatureStore._lastRequestedTemperature',
      context: context);

  @override
  double? get _lastRequestedTemperature {
    _$_lastRequestedTemperatureAtom.reportRead();
    return super._lastRequestedTemperature;
  }

  @override
  set _lastRequestedTemperature(double? value) {
    _$_lastRequestedTemperatureAtom
        .reportWrite(value, super._lastRequestedTemperature, () {
      super._lastRequestedTemperature = value;
    });
  }

  late final _$_TargetTemperatureStoreActionController =
      ActionController(name: '_TargetTemperatureStore', context: context);

  @override
  void changeTargetTemperature(double value) {
    final _$actionInfo = _$_TargetTemperatureStoreActionController.startAction(
        name: '_TargetTemperatureStore.changeTargetTemperature');
    try {
      return super.changeTargetTemperature(value);
    } finally {
      _$_TargetTemperatureStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onData(WsInboundMessage<WsInboundMessagePayload> message) {
    final _$actionInfo = _$_TargetTemperatureStoreActionController.startAction(
        name: '_TargetTemperatureStore._onData');
    try {
      return super._onData(message);
    } finally {
      _$_TargetTemperatureStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
temperatureHistory: ${temperatureHistory},
targetTemperature: ${targetTemperature},
lastRequestedTemperature: ${lastRequestedTemperature}
    ''';
  }
}
