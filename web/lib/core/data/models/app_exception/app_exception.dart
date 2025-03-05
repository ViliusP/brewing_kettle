import 'package:brew_kettle_dashboard/localizations/localization.dart';

enum ExceptionType { unknown }

class AppException implements Exception {
  final Exception? _inner;
  final String message;
  final ExceptionType type;

  AppException({required this.message, this.type = ExceptionType.unknown}) : _inner = null;

  AppException.of(Exception exception)
    : message = exception.toString(),
      type = ExceptionType.unknown,
      _inner = exception;

  @override
  String toString() => 'AppError{message: $message, type: $type, inner: $_inner}';

  String toLocalizedMessage(AppLocalizations localizations) {
    return switch (type) {
      // ExceptionType.unimplemented => localizations.errorUnimplemented,
      ExceptionType.unknown => '${localizations.exceptionUnknown} ($message)',
    };
  }
}
