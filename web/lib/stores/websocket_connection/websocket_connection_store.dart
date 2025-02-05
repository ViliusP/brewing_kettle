import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:brew_kettle_dashboard/core/data/models/store/ws_listener.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:mobx/mobx.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'websocket_connection_store.g.dart';

// ignore: library_private_types_in_public_api
class WebSocketConnectionStore = _WebSocketConnectionStore
    with _$WebSocketConnectionStore;

abstract class _WebSocketConnectionStore with Store {
  final List<StoreWebSocketListener> _listeners = [];

  WebSocketChannel? _channel;

  _WebSocketConnectionStore();

  @computed
  List<WsInboundMessageSimple> get messages => _messages.toList();

  @observable
  ObservableList<WsInboundMessageSimple> _messages = ObservableList.of([]);

  @computed
  List<WsInboundMessageSimple> get archive => _archive.toList();

  @observable
  ObservableList<WsInboundMessageSimple> _archive = ObservableList.of([]);

  @computed
  WebSocketConnectionStatus get status => _status;

  @observable
  WebSocketConnectionStatus _status = WebSocketConnectionStatus.idle;

  @computed
  String? get connectedTo => _connectedTo?.toString();

  @observable
  Uri? _connectedTo;

  @action
  Future connect(Uri address) async {
    if (_channel != null) {
      log("Connecting failed. There is active connection to server, please close it first");
      return;
    }

    log("Connecting to $address");

    _status = WebSocketConnectionStatus.connected;
    _channel = IOWebSocketChannel.connect(
      address,
      pingInterval: Duration(seconds: 5),
    );
    try {
      await _channel?.ready;
    } on SocketException catch (e) {
      log("Error occured while connecting to websocket channel ${e.message}");
      _status = WebSocketConnectionStatus.error;
      _clean();
      return;
    } on WebSocketChannelException catch (e) {
      _status = WebSocketConnectionStatus.error;
      _clean();
      log(
        "Error occured while connecting to websocket channel.",
        error: e.toString(),
      );
      return;
    }

    _status = WebSocketConnectionStatus.connected;
    log("Connection successful");

    _channel!.stream.listen(_onData, onError: _onError, onDone: _onDone);
    _connectedTo = address;
  }

  @action
  void close([int code = WebSocketStatus.normalClosure, String? reason]) {
    log("Closing connection with $_connectedTo. Code $code. Reason $reason");
    _channel?.sink.close(code, reason);
    _clean();
    _status = WebSocketConnectionStatus.fromCloseCode(code);
  }

  @action
  void _onData(dynamic data) {
    if (_connectedTo == null || _channel == null) {
      log("Unexpected: got message when connection is null");
      _status = WebSocketConnectionStatus.finishedNoStatus;
      _clean();
      return;
    }
    WsInboundMessageSimple message = WsInboundMessageSimple.create(
      data,
      _connectedTo!,
    );

    if (message is WsInboundMessage) {
      for (var listener in _listeners) {
        listener.onData(message);
      }
    }

    if (message is WsInboundMessage &&
        message.type != InboundMessageType.heaterControllerState) {
      String msg = "Got data from [$connectedTo]: ${data.toString()}";
      if (msg.length > 75) {
        log("${msg.substring(0, 75)}...");
      } else {
        log(msg);
      }
    }

    _messages.add(message);
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

  void message(String value) {
    _channel?.sink.add(value);
  }

  void _clean() {
    _channel = null;
    _connectedTo = null;
    _messages.clear();
  }

  void subscribe(StoreWebSocketListener listener) {
    _listeners.add(listener);
  }
}
