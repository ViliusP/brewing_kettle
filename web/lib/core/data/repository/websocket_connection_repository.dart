import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketConnectionRepository {
  WebSocketChannel? _channel;
  bool get isConnected => _channel != null;

  WebSocketConnectionRepository();

  Future connect({
    required Uri address,
    void Function(dynamic event)? onData,
    Function? onError,
    void Function()? onDone,
  }) async {
    _channel = switch (kIsWeb) {
      true => WebSocketChannel.connect(address),
      _ => IOWebSocketChannel.connect(address, pingInterval: Duration(seconds: 5)),
    };

    await _channel?.ready;
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
