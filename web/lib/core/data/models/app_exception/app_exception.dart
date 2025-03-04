import 'package:brew_kettle_dashboard/localizations/localization.dart';

enum ErrorType { unimplemented, unknown }

class AppException implements Exception {
  final Exception? _inner;
  final String message;
  final ErrorType type;

  AppException({required this.message, this.type = ErrorType.unknown}) : _inner = null;

  AppException.of(Exception exception)
    : message = exception.toString(),
      type = ErrorType.unknown,
      _inner = exception;

  @override
  String toString() => 'AppError{message: $message, type: $type, inner: $_inner}';

  String toLocalizedMessage(AppLocalizations localizations) {
    return switch (type) {
      ErrorType.unimplemented => localizations.errorUnimplemented,
      ErrorType.unknown => '${localizations.errorUnknown} ($message)',
    };
  }
}
