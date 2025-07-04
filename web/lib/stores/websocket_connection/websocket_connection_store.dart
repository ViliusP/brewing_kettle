import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:brew_kettle_dashboard/core/data/models/app_exceptions/app_exception.dart';
import 'package:brew_kettle_dashboard/core/data/models/store/ws_listener.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/messages_archive.dart';
import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:brew_kettle_dashboard/stores/exception/exception_store.dart';
import 'package:mobx/mobx.dart';

part 'websocket_connection_store.g.dart';

// ignore: library_private_types_in_public_api
class WebSocketConnectionStore = _WebSocketConnectionStore with _$WebSocketConnectionStore;

abstract class _WebSocketConnectionStore with Store {
  final Repository _repository;
  final ExceptionStore _exceptionStore;

  final List<StoreWebSocketListener> _listeners = [];

  _WebSocketConnectionStore({
    required Repository repository,
    required ExceptionStore exceptionStore,
  }) : _repository = repository,
       _exceptionStore = exceptionStore;

  @computed
  WebSocketConnectionStatus get status => _status;

  @observable
  WebSocketConnectionStatus _status = WebSocketConnectionStatus.idle;

  @computed
  String? get connectedTo => _connectedTo?.toString();

  @observable
  Uri? _connectedTo;

  // ----------
  // ARCHIVE
  // ----------
  @computed
  UnmodifiableListView<WsInboundMessageSimple> get messages => _archive.data;

  @computed
  String get logs => _archive.jsonLog;

  @observable
  MessagesArchive _archive = MessagesArchive();

  @action
  Future connect(Uri baseUri) async {
    if (_repository.webSocketConnection.isConnected) {
      log("Connecting failed. There is active connection to server, please close it first");
      return;
    }

    log("Connecting to $baseUri");

    _status = WebSocketConnectionStatus.connecting;

    try {
      await _repository.webSocketConnection.connect(
        baseUri: baseUri,
        onData: _onData,
        onError: _onError,
        onDone: _onDone,
      );
    } on Exception catch (e) {
      log("Error occured while connecting to websocket channel ${e.toString()}");
      _status = WebSocketConnectionStatus.error;
      switch (e) {
        case TimeoutException e:
          _exceptionStore.push(AppException(e, type: ExceptionType.websocketConnectionTimeout));
          break;
        default:
          _exceptionStore.push(e);
          break;
      }
      _clean();
      return;
    }
    _status = WebSocketConnectionStatus.connected;
    log("Connection successful");

    _connectedTo = baseUri;
  }

  @action
  void close([int code = WebSocketStatus.normalClosure, String? reason]) {
    log("Closing connection with $_connectedTo. Code $code. Reason $reason");
    _repository.webSocketConnection.close(code, reason);
    _clean();
    _status = WebSocketConnectionStatus.fromCloseCode(code);
  }

  @action
  void _onData(dynamic data) {
    if (!_repository.webSocketConnection.isConnected) {
      log("Unexpected: got message when connection is null");
      _status = WebSocketConnectionStatus.finishedNoStatus;
      _clean();
      return;
    }
    WsInboundMessageSimple message = WsInboundMessageSimple.create(data, _connectedTo!);

    if (message is WsInboundMessage) {
      for (var listener in _listeners) {
        listener.onData(message);
      }
    }

    if (message is WsInboundMessage && message.type != InboundMessageType.heaterControllerState) {
      String msg = "Got data from [$connectedTo]: ${data.toString()}";
      if (msg.length > 75) {
        log("${msg.substring(0, 75)}...");
      } else {
        log(msg);
      }
    }

    _archive.add(message);
  }

  void _onError(dynamic maybeError) {
    log("Error in stream with $_connectedTo: ${maybeError.toString()}");

    for (var listener in _listeners) {
      listener.onError?.call(maybeError);
    }
  }

  void _onDone() {
    log("Stream with $_connectedTo done");
    _status = WebSocketConnectionStatus.finished;
    close(WebSocketStatus.normalClosure);
  }

  void message(String value) => _repository.webSocketConnection.message(value);

  void subscribe(StoreWebSocketListener listener) => _listeners.add(listener);

  void _clean() {
    _connectedTo = null;
    _archive.clear();
  }
}
