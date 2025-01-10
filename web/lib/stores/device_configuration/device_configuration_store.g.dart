// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_configuration_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DeviceConfigurationStore on _DeviceConfigurationStore, Store {
  Computed<bool>? _$waitingResponseComputed;

  @override
  bool get waitingResponse =>
      (_$waitingResponseComputed ??= Computed<bool>(() => super.waitingResponse,
              name: '_DeviceConfigurationStore.waitingResponse'))
          .value;

  late final _$configurationAtom =
      Atom(name: '_DeviceConfigurationStore.configuration', context: context);

  @override
  DeviceConfiguration? get configuration {
    _$configurationAtom.reportRead();
    return super.configuration;
  }

  @override
  set configuration(DeviceConfiguration? value) {
    _$configurationAtom.reportWrite(value, super.configuration, () {
      super.configuration = value;
    });
  }

  late final _$_waitingResponseAtom = Atom(
      name: '_DeviceConfigurationStore._waitingResponse', context: context);

  @override
  bool get _waitingResponse {
    _$_waitingResponseAtom.reportRead();
    return super._waitingResponse;
  }

  @override
  set _waitingResponse(bool value) {
    _$_waitingResponseAtom.reportWrite(value, super._waitingResponse, () {
      super._waitingResponse = value;
    });
  }

  late final _$_DeviceConfigurationStoreActionController =
      ActionController(name: '_DeviceConfigurationStore', context: context);

  @override
  void request() {
    final _$actionInfo = _$_DeviceConfigurationStoreActionController
        .startAction(name: '_DeviceConfigurationStore.request');
    try {
      return super.request();
    } finally {
      _$_DeviceConfigurationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onData(WsInboundMessage<WsInboundMessagePayload> message) {
    final _$actionInfo = _$_DeviceConfigurationStoreActionController
        .startAction(name: '_DeviceConfigurationStore._onData');
    try {
      return super._onData(message);
    } finally {
      _$_DeviceConfigurationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
configuration: ${configuration},
waitingResponse: ${waitingResponse}
    ''';
  }
}
