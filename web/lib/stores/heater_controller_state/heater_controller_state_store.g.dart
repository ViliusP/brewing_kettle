// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heater_controller_state_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HeaterControllerStateStore on _HeaterControllerStateStore, Store {
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

  late final _$_currentTemperatureAtom = Atom(
      name: '_HeaterControllerStateStore._currentTemperature',
      context: context);

  @override
  double? get _currentTemperature {
    _$_currentTemperatureAtom.reportRead();
    return super._currentTemperature;
  }

  @override
  set _currentTemperature(double? value) {
    _$_currentTemperatureAtom.reportWrite(value, super._currentTemperature, () {
      super._currentTemperature = value;
    });
  }

  late final _$_HeaterControllerStateStoreActionController =
      ActionController(name: '_HeaterControllerStateStore', context: context);

  @override
  void request() {
    final _$actionInfo = _$_HeaterControllerStateStoreActionController
        .startAction(name: '_HeaterControllerStateStore.request');
    try {
      return super.request();
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
temperatureHistory: ${temperatureHistory},
currentTemperature: ${currentTemperature}
    ''';
  }
}
