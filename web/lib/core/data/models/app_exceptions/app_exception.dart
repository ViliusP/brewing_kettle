import 'dart:io';

import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ExceptionType {
  httpConnectionTimeout,
  httpSendTimeout,
  httpReceiveTimeout,
  httpBadCertificate,
  httpBadResponse,
  httpCancel,
  httpConnectionError,
  httpUnknown,
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
    return switch (exception) {
      AppException _ => exception,
      WebSocketChannelException e => _parseWebsocketException(e),
      DioException e => _parseDioException(e),
      _ => AppException(exception),
    };
  }

  static AppException _parseWebsocketException(WebSocketChannelException exception) {
    Object? inner = exception.inner;
    if (inner is SocketException && inner.osError?.errorCode == 111) {
      return AppException(exception, type: ExceptionType.websocketConnectionRefused);
    }
    if (inner is SocketException && inner.osError?.errorCode == -2) {
      return AppException(exception, type: ExceptionType.websocketClientLookupFailed);
    }
    return AppException(exception, type: ExceptionType.websocketConnectionGeneric);
  }

  static AppException _parseDioException(DioException exception) {
    return switch (exception.type) {
      DioExceptionType.connectionTimeout => AppException(
        exception,
        type: ExceptionType.httpConnectionTimeout,
      ),
      DioExceptionType.sendTimeout => AppException(exception, type: ExceptionType.httpSendTimeout),
      DioExceptionType.receiveTimeout => AppException(
        exception,
        type: ExceptionType.httpReceiveTimeout,
      ),
      DioExceptionType.badCertificate => AppException(
        exception,
        type: ExceptionType.httpBadCertificate,
      ),
      DioExceptionType.badResponse => AppException(
        exception,
        type: ExceptionType.httpUnknown,
        data: {"code": exception.response?.statusCode.toString() ?? "000"},
      ),
      DioExceptionType.cancel => AppException(exception, type: ExceptionType.httpCancel),
      DioExceptionType.connectionError => AppException(
        exception,
        type: ExceptionType.httpConnectionError,
      ),
      DioExceptionType.unknown => AppException(exception, type: ExceptionType.httpUnknown),
    };
  }

  @override
  String toString() => 'AppError{inner: $_inner, type: $type}';

  String toLocalizedMessage(AppLocalizations localizations) {
    return switch (type) {
      ExceptionType.httpConnectionTimeout => localizations.exceptionHttpConnectionTimeout,
      ExceptionType.httpSendTimeout => localizations.exceptionHttpSendTimeout,
      ExceptionType.httpReceiveTimeout => localizations.exceptionHttpReceiveTimeout,
      ExceptionType.httpBadCertificate => localizations.exceptionHttpBadCertificate,
      ExceptionType.httpBadResponse => localizations.exceptionHttpBadResponse(
        data['code'] ?? '000',
      ),
      ExceptionType.httpCancel => localizations.exceptionHttpCancel,
      ExceptionType.httpConnectionError => localizations.exceptionHttpConnectionError,
      ExceptionType.httpUnknown => localizations.exceptionHttpUnknown,
      ExceptionType.websocketConnectionGeneric => localizations.exceptionFailedToConnectToDevice,
      ExceptionType.websocketConnectionTimeout => localizations.exceptionDeviceConnectionTimeout,
      ExceptionType.websocketClientLookupFailed => localizations.exceptionAddressLookupFailed,
      ExceptionType.websocketConnectionRefused => localizations.exceptionConnectionRefused,
      ExceptionType.unknown => '${localizations.exceptionUnknown} ($_inner)',
    };
  }
}
