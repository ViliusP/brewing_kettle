// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_snapshot_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$DeviceSnapshotStore on _DeviceSnapshotStore, Store {
  Computed<bool>? _$waitingResponseComputed;

  @override
  bool get waitingResponse =>
      (_$waitingResponseComputed ??= Computed<bool>(() => super.waitingResponse,
              name: '_DeviceSnapshotStore.waitingResponse'))
          .value;

  late final _$snapshotAtom =
      Atom(name: '_DeviceSnapshotStore.snapshot', context: context);

  @override
  DeviceSnapshot? get snapshot {
    _$snapshotAtom.reportRead();
    return super.snapshot;
  }

  @override
  set snapshot(DeviceSnapshot? value) {
    _$snapshotAtom.reportWrite(value, super.snapshot, () {
      super.snapshot = value;
    });
  }

  late final _$_waitingResponseAtom =
      Atom(name: '_DeviceSnapshotStore._waitingResponse', context: context);

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

  late final _$_DeviceSnapshotStoreActionController =
      ActionController(name: '_DeviceSnapshotStore', context: context);

  @override
  void request() {
    final _$actionInfo = _$_DeviceSnapshotStoreActionController.startAction(
        name: '_DeviceSnapshotStore.request');
    try {
      return super.request();
    } finally {
      _$_DeviceSnapshotStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onData(WsInboundMessage<WsInboundMessagePayload> message) {
    final _$actionInfo = _$_DeviceSnapshotStoreActionController.startAction(
        name: '_DeviceSnapshotStore._onData');
    try {
      return super._onData(message);
    } finally {
      _$_DeviceSnapshotStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
snapshot: ${snapshot},
waitingResponse: ${waitingResponse}
    ''';
  }
}
