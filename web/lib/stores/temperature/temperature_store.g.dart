// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temperature_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TemperatureStore on _TemperatureStore, Store {
  Computed<double?>? _$currentTemperatureComputed;

  @override
  double? get currentTemperature => (_$currentTemperatureComputed ??=
          Computed<double?>(() => super.currentTemperature,
              name: '_TemperatureStore.currentTemperature'))
      .value;

  late final _$_currentTemperatureAtom =
      Atom(name: '_TemperatureStore._currentTemperature', context: context);

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

  late final _$_TemperatureStoreActionController =
      ActionController(name: '_TemperatureStore', context: context);

  @override
  void request() {
    final _$actionInfo = _$_TemperatureStoreActionController.startAction(
        name: '_TemperatureStore.request');
    try {
      return super.request();
    } finally {
      _$_TemperatureStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onData(WsInboundMessage<WsInboundMessagePayload> message) {
    final _$actionInfo = _$_TemperatureStoreActionController.startAction(
        name: '_TemperatureStore._onData');
    try {
      return super._onData(message);
    } finally {
      _$_TemperatureStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
currentTemperature: ${currentTemperature}
    ''';
  }
}
