// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heater_controller_state_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HeaterControllerStateStore on _HeaterControllerStateStore, Store {
  Computed<double?>? _$lastRequestedTemperatureComputed;

  @override
  double? get lastRequestedTemperature =>
      (_$lastRequestedTemperatureComputed ??= Computed<double?>(
              () => super.lastRequestedTemperature,
              name: '_HeaterControllerStateStore.lastRequestedTemperature'))
          .value;
  Computed<List<TimeseriesViewEntry>>? _$temperatureHistoryComputed;

  @override
  List<TimeseriesViewEntry> get temperatureHistory =>
      (_$temperatureHistoryComputed ??= Computed<List<TimeseriesViewEntry>>(
              () => super.temperatureHistory,
              name: '_HeaterControllerStateStore.temperatureHistory'))
          .value;
  Computed<double?>? _$currentTemperatureComputed;

  @override
  double? get currentTemperature => (_$currentTemperatureComputed ??=
          Computed<double?>(() => super.currentTemperature,
              name: '_HeaterControllerStateStore.currentTemperature'))
      .value;
  Computed<double?>? _$targetTemperatureComputed;

  @override
  double? get targetTemperature => (_$targetTemperatureComputed ??=
          Computed<double?>(() => super.targetTemperature,
              name: '_HeaterControllerStateStore.targetTemperature'))
      .value;

  late final _$_lastRequestedTemperatureAtom = Atom(
      name: '_HeaterControllerStateStore._lastRequestedTemperature',
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

  late final _$_temperatureHistoryAtom = Atom(
      name: '_HeaterControllerStateStore._temperatureHistory',
      context: context);

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

  late final _$stateAtom =
      Atom(name: '_HeaterControllerStateStore.state', context: context);

  @override
  HeaterControllerState? get state {
    _$stateAtom.reportRead();
    return super.state;
  }

  @override
  set state(HeaterControllerState? value) {
    _$stateAtom.reportWrite(value, super.state, () {
      super.state = value;
    });
  }

  late final _$_HeaterControllerStateStoreActionController =
      ActionController(name: '_HeaterControllerStateStore', context: context);

  @override
  void changeTargetTemperature(double value) {
    final _$actionInfo =
        _$_HeaterControllerStateStoreActionController.startAction(
            name: '_HeaterControllerStateStore.changeTargetTemperature');
    try {
      return super.changeTargetTemperature(value);
    } finally {
      _$_HeaterControllerStateStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeMode(HeaterMode value) {
    final _$actionInfo = _$_HeaterControllerStateStoreActionController
        .startAction(name: '_HeaterControllerStateStore.changeMode');
    try {
      return super.changeMode(value);
    } finally {
      _$_HeaterControllerStateStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onData(WsInboundMessage<WsInboundMessagePayload> message) {
    final _$actionInfo = _$_HeaterControllerStateStoreActionController
        .startAction(name: '_HeaterControllerStateStore._onData');
    try {
      return super._onData(message);
    } finally {
      _$_HeaterControllerStateStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
state: ${state},
lastRequestedTemperature: ${lastRequestedTemperature},
temperatureHistory: ${temperatureHistory},
currentTemperature: ${currentTemperature},
targetTemperature: ${targetTemperature}
    ''';
  }
}
