import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:mobx/mobx.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'websocket_connection_store.g.dart';

// ignore: library_private_types_in_public_api
class WebSocketConnectionStore = _WebSocketConnectionStore
    with _$WebSocketConnectionStore;

abstract class _WebSocketConnectionStore with Store {
  _WebSocketConnectionStore() {
    // _timer = Timer.periodic(const Duration(seconds: 1),
    //     (_) => _streamController.add(_random.nextInt(100)));
  }

  @computed
  WebSocketConnectionStatus get status => _status;

  @observable
  WebSocketConnectionStatus _status = WebSocketConnectionStatus.idle;

  WebSocketChannel? _channel;

  @computed
  String? get connectedTo => _connectedTo;

  @observable
  String? _connectedTo;

  @action
  Future connect(String address) async {
    final Uri uri;

    try {
      uri = Uri.parse(address);
    } catch (e) {
      log("Cannot parse given address");
      _status = WebSocketConnectionStatus.error;
      return;
    }

    log("Connecting to $uri");

    _status = WebSocketConnectionStatus.connected;
    _channel = WebSocketChannel.connect(uri);
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

  void _onData(dynamic data) {
    log("Got data from $_connectedTo: ${data.toString()}");
  }

  void _onError(dynamic maybeError) {
    log("Error in stream with $_connectedTo: ${maybeError.toString()}");
  }

  void _onDone() {
    log("Stream with $_connectedTo done");
    _status = WebSocketConnectionStatus.finished;
    _clean();
  }

  void message(String value) {
    _channel?.sink.add(value);
  }

  void _clean() {
    _channel = null;
    _connectedTo = null;
  }

  // ignore: avoid_void_async
  void dispose() async {
    close();
  }
}

enum WebSocketConnectionStatus {
  // Waiting for connection.
  idle,

  /// Connecting.
  connecting,

  // Ready for communication.
  connected,

  /// Error while connecting and now idling.
  error,

  /// Connection closed succesfully and now idling.
  finished,

  /// Connection with error and now idling.
  finishedWithError,

  /// Connection ended with no status and now idling.
  finishedNoStatus,

  undefined;

  static const _errorCloseCodes = [
    WebSocketStatus.protocolError,
    WebSocketStatus.goingAway,
    WebSocketStatus.unsupportedData,
    WebSocketStatus.abnormalClosure,
    WebSocketStatus.invalidFramePayloadData,
    WebSocketStatus.policyViolation,
    WebSocketStatus.messageTooBig,
    WebSocketStatus.missingMandatoryExtension,
    WebSocketStatus.internalServerError,
  ];

  static WebSocketConnectionStatus fromCloseCode(int value) {
    if (_errorCloseCodes.contains(value)) {
      return finishedWithError;
    }

    return switch (value) {
      WebSocketStatus.normalClosure || WebSocketStatus.goingAway => finished,
      WebSocketStatus.noStatusReceived => finishedNoStatus,
      WebSocketStatus.reserved1004 || WebSocketStatus.reserved1015 => undefined,
      _ => undefined
    };
  }
}

class WebSocketMessage {
  final String data;
  final DateTime time;

  WebSocketMessage._(this.data, this.time);

  factory WebSocketMessage.create(String data) {
    try {
      var decodedJSON = json.decode(data) as Map<String, dynamic>;
      return WebSocketMessageJson._(decodedJSON, data, DateTime.now());
    } catch (e) {
      return WebSocketMessage._(data, DateTime.now());
    }
  }
}

class WebSocketMessageJson extends WebSocketMessage {
  UnmodifiableMapView<String, dynamic> get json => UnmodifiableMapView(_json);
  final Map<String, dynamic> _json;

  WebSocketMessageJson._(
    this._json,
    String data,
    DateTime time,
  ) : super._(data, time);
}
