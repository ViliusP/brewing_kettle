import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String _channelPath = "ws_1";
const Duration _connectTimeout = Duration(seconds: 5);

class WebSocketConnectionRepository {
  WebSocketChannel? _channel;
  bool get isConnected => _channel != null;

  WebSocketConnectionRepository();

  Future connect({
    required Uri baseUri,
    void Function(dynamic event)? onData,
    Function? onError,
    void Function()? onDone,
  }) async {
    final uri = baseUri.replace(path: _channelPath);
    try {
      if (kIsWeb) {
        _channel = WebSocketChannel.connect(uri);
        await _channel?.ready.timeout(
          _connectTimeout,
          onTimeout: () {
            throw TimeoutException("WebSocket connection timeout", _connectTimeout);
          },
        );
      } else {
        _channel = IOWebSocketChannel.connect(
          uri,
          pingInterval: Duration(seconds: 5),
          connectTimeout: _connectTimeout,
        );
        await _channel?.ready;
      }

      _channel!.stream.listen(
        onData,
        onDone: () {
          onDone?.call();
          _clean();
        },
        onError: (e) {
          onError?.call(e);
          _clean();
        },
      );
    } catch (e) {
      _clean();
      rethrow;
    }
  }

  void message(String value) {
    _channel?.sink.add(value);
  }

  void close([int code = WebSocketStatus.normalClosure, String? reason]) {
    _channel?.sink.close(code, reason);
  }

  void _clean() {
    _channel = null;
  }
}
