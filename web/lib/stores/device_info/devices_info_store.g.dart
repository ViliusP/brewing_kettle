// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_info_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DevicesInfoStore on _DevicesInfoStore, Store {
  Computed<bool>? _$waitingResponseComputed;

  @override
  bool get waitingResponse =>
      (_$waitingResponseComputed ??= Computed<bool>(() => super.waitingResponse,
              name: '_DevicesInfoStore.waitingResponse'))
          .value;

  late final _$controllersAtom =
      Atom(name: '_DevicesInfoStore.controllers', context: context);

  @override
  SystemControllers? get controllers {
    _$controllersAtom.reportRead();
    return super.controllers;
  }

  @override
  set controllers(SystemControllers? value) {
    _$controllersAtom.reportWrite(value, super.controllers, () {
      super.controllers = value;
    });
  }

  late final _$_waitingResponseAtom =
      Atom(name: '_DevicesInfoStore._waitingResponse', context: context);

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

  late final _$_DevicesInfoStoreActionController =
      ActionController(name: '_DevicesInfoStore', context: context);

  @override
  void request() {
    final _$actionInfo = _$_DevicesInfoStoreActionController.startAction(
        name: '_DevicesInfoStore.request');
    try {
      return super.request();
    } finally {
      _$_DevicesInfoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onData(WsInboundMessage<WsInboundMessagePayload> message) {
    final _$actionInfo = _$_DevicesInfoStoreActionController.startAction(
        name: '_DevicesInfoStore._onData');
    try {
      return super._onData(message);
    } finally {
      _$_DevicesInfoStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
controllers: ${controllers},
waitingResponse: ${waitingResponse}
    ''';
  }
}
