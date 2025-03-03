// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'websocket_connection_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$WebSocketConnectionStore on _WebSocketConnectionStore, Store {
  Computed<WebSocketConnectionStatus>? _$statusComputed;

  @override
  WebSocketConnectionStatus get status =>
      (_$statusComputed ??= Computed<WebSocketConnectionStatus>(
            () => super.status,
            name: '_WebSocketConnectionStore.status',
          ))
          .value;
  Computed<String?>? _$connectedToComputed;

  @override
  String? get connectedTo =>
      (_$connectedToComputed ??= Computed<String?>(
            () => super.connectedTo,
            name: '_WebSocketConnectionStore.connectedTo',
          ))
          .value;
  Computed<UnmodifiableListView<WsInboundMessageSimple>>? _$messagesComputed;

  @override
  UnmodifiableListView<WsInboundMessageSimple> get messages =>
      (_$messagesComputed ??= Computed<UnmodifiableListView<WsInboundMessageSimple>>(
            () => super.messages,
            name: '_WebSocketConnectionStore.messages',
          ))
          .value;
  Computed<String>? _$logsComputed;

  @override
  String get logs =>
      (_$logsComputed ??= Computed<String>(
            () => super.logs,
            name: '_WebSocketConnectionStore.logs',
          ))
          .value;

  late final _$_statusAtom = Atom(name: '_WebSocketConnectionStore._status', context: context);

  @override
  WebSocketConnectionStatus get _status {
    _$_statusAtom.reportRead();
    return super._status;
  }

  @override
  set _status(WebSocketConnectionStatus value) {
    _$_statusAtom.reportWrite(value, super._status, () {
      super._status = value;
    });
  }

  late final _$_connectedToAtom = Atom(
    name: '_WebSocketConnectionStore._connectedTo',
    context: context,
  );

  @override
  Uri? get _connectedTo {
    _$_connectedToAtom.reportRead();
    return super._connectedTo;
  }

  @override
  set _connectedTo(Uri? value) {
    _$_connectedToAtom.reportWrite(value, super._connectedTo, () {
      super._connectedTo = value;
    });
  }

  late final _$_archiveAtom = Atom(name: '_WebSocketConnectionStore._archive', context: context);

  @override
  MessagesArchive get _archive {
    _$_archiveAtom.reportRead();
    return super._archive;
  }

  @override
  set _archive(MessagesArchive value) {
    _$_archiveAtom.reportWrite(value, super._archive, () {
      super._archive = value;
    });
  }

  late final _$connectAsyncAction = AsyncAction(
    '_WebSocketConnectionStore.connect',
    context: context,
  );

  @override
  Future<dynamic> connect(Uri address) {
    return _$connectAsyncAction.run(() => super.connect(address));
  }

  late final _$_WebSocketConnectionStoreActionController = ActionController(
    name: '_WebSocketConnectionStore',
    context: context,
  );

  @override
  void close([int code = WebSocketStatus.normalClosure, String? reason]) {
    final _$actionInfo = _$_WebSocketConnectionStoreActionController.startAction(
      name: '_WebSocketConnectionStore.close',
    );
    try {
      return super.close(code, reason);
    } finally {
      _$_WebSocketConnectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _onData(dynamic data) {
    final _$actionInfo = _$_WebSocketConnectionStoreActionController.startAction(
      name: '_WebSocketConnectionStore._onData',
    );
    try {
      return super._onData(data);
    } finally {
      _$_WebSocketConnectionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
status: ${status},
connectedTo: ${connectedTo},
messages: ${messages},
logs: ${logs}
    ''';
  }
}
