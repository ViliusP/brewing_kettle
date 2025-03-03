// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heater_controller_state_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$HeaterControllerStateStore on _HeaterControllerStateStore, Store {
  Computed<bool>? _$isModeChangingComputed;

  @override
  bool get isModeChanging =>
      (_$isModeChangingComputed ??= Computed<bool>(() => super.isModeChanging,
              name: '_HeaterControllerStateStore.isModeChanging'))
          .value;
  Computed<List<TimeSeriesViewEntry>>? _$stateHistoryComputed;

  @override
  List<TimeSeriesViewEntry> get stateHistory => (_$stateHistoryComputed ??=
          Computed<List<TimeSeriesViewEntry>>(() => super.stateHistory,
              name: '_HeaterControllerStateStore.stateHistory'))
      .value;
  Computed<double?>? _$currentTemperatureComputed;

  @override
  double? get currentTemperature => (_$currentTemperatureComputed ??=
          Computed<double?>(() => super.currentTemperature,
              name: '_HeaterControllerStateStore.currentTemperature'))
      .value;
  Computed<HeaterStatus?>? _$statusComputed;

  @override
  HeaterStatus? get status =>
      (_$statusComputed ??= Computed<HeaterStatus?>(() => super.status,
              name: '_HeaterControllerStateStore.status'))
          .value;
  Computed<double?>? _$targetTemperatureComputed;

  @override
  double? get targetTemperature => (_$targetTemperatureComputed ??=
          Computed<double?>(() => super.targetTemperature,
              name: '_HeaterControllerStateStore.targetTemperature'))
      .value;
  Computed<double?>? _$requestedTemperatureComputed;

  @override
  double? get requestedTemperature => (_$requestedTemperatureComputed ??=
          Computed<double?>(() => super.requestedTemperature,
              name: '_HeaterControllerStateStore.requestedTemperature'))
      .value;
  Computed<double?>? _$powerComputed;

  @override
  double? get power => (_$powerComputed ??= Computed<double?>(() => super.power,
          name: '_HeaterControllerStateStore.power'))
      .value;
  Computed<double?>? _$requestedPowerComputed;

  @override
  double? get requestedPower => (_$requestedPowerComputed ??= Computed<double?>(
          () => super.requestedPower,
          name: '_HeaterControllerStateStore.requestedPower'))
      .value;

  late final _$_stateAtom =
      Atom(name: '_HeaterControllerStateStore._state', context: context);

  @override
  HeaterControllerState? get _state {
    _$_stateAtom.reportRead();
    return super._state;
  }

  @override
  set _state(HeaterControllerState? value) {
    _$_stateAtom.reportWrite(value, super._state, () {
      super._state = value;
    });
  }

  late final _$_stateHistoryAtom =
      Atom(name: '_HeaterControllerStateStore._stateHistory', context: context);

  @override
  ObservableList<TimeSeriesEntry<HeaterControllerState>> get _stateHistory {
    _$_stateHistoryAtom.reportRead();
    return super._stateHistory;
  }

  @override
  set _stateHistory(
      ObservableList<TimeSeriesEntry<HeaterControllerState>> value) {
    _$_stateHistoryAtom.reportWrite(value, super._stateHistory, () {
      super._stateHistory = value;
    });
  }

  late final _$_requestedModeAtom = Atom(
      name: '_HeaterControllerStateStore._requestedMode', context: context);

  @override
  HeaterMode? get _requestedMode {
    _$_requestedModeAtom.reportRead();
    return super._requestedMode;
  }

  @override
  set _requestedMode(HeaterMode? value) {
    _$_requestedModeAtom.reportWrite(value, super._requestedMode, () {
      super._requestedMode = value;
    });
  }

  late final _$_requestedTemperatureAtom = Atom(
      name: '_HeaterControllerStateStore._requestedTemperature',
      context: context);

  @override
  double? get _requestedTemperature {
    _$_requestedTemperatureAtom.reportRead();
    return super._requestedTemperature;
  }

  @override
  set _requestedTemperature(double? value) {
    _$_requestedTemperatureAtom.reportWrite(value, super._requestedTemperature,
        () {
      super._requestedTemperature = value;
    });
  }

  late final _$_requestedPowerAtom = Atom(
      name: '_HeaterControllerStateStore._requestedPower', context: context);

  @override
  double? get _requestedPower {
    _$_requestedPowerAtom.reportRead();
    return super._requestedPower;
  }

  @override
  set _requestedPower(double? value) {
    _$_requestedPowerAtom.reportWrite(value, super._requestedPower, () {
      super._requestedPower = value;
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
  void changePower(double value) {
    final _$actionInfo = _$_HeaterControllerStateStoreActionController
        .startAction(name: '_HeaterControllerStateStore.changePower');
    try {
      return super.changePower(value);
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
isModeChanging: ${isModeChanging},
stateHistory: ${stateHistory},
currentTemperature: ${currentTemperature},
status: ${status},
targetTemperature: ${targetTemperature},
requestedTemperature: ${requestedTemperature},
power: ${power},
requestedPower: ${requestedPower}
    ''';
  }
}
