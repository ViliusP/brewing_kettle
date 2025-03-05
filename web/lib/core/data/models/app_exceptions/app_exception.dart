import 'dart:io';

import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ExceptionType {
  websocketConnectionGeneric,
  websocketConnectionTimeout,
  websocketClientLookupFailed,
  websocketConnectionRefused,
  unknown,
}

class AppException implements Exception {
  final Exception _inner;
  final ExceptionType type;
  final Map<String, String> data;

  const AppException(Exception exception, {this.type = ExceptionType.unknown, this.data = const {}})
    : _inner = exception;

  factory AppException.of(Exception exception) {
    if (exception is AppException) return exception;
    if (exception is WebSocketChannelException) {
      Object? inner = exception.inner;
      if (inner is SocketException && inner.osError?.errorCode == 111) {
        return AppException(exception, type: ExceptionType.websocketConnectionRefused);
      }
      if (inner is SocketException && inner.osError?.errorCode == -2) {
        return AppException(exception, type: ExceptionType.websocketClientLookupFailed);
      }
      return AppException(exception, type: ExceptionType.websocketConnectionGeneric);
    }

    return AppException(exception);
  }

  @override
  String toString() => 'AppError{inner: $_inner, type: $type}';

  String toLocalizedMessage(AppLocalizations localizations) {
    return switch (type) {
      ExceptionType.websocketConnectionGeneric => localizations.exceptionFailedToConnectToDevice,
      ExceptionType.websocketConnectionTimeout => localizations.exceptionDeviceConnectionTimeout,
      ExceptionType.websocketClientLookupFailed => localizations.exceptionAddressLookupFailed,
      ExceptionType.websocketConnectionRefused => localizations.exceptionConnectionRefused,
      ExceptionType.unknown => '${localizations.exceptionUnknown} ($_inner)',
    };
  }
}
