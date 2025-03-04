import 'package:brew_kettle_dashboard/localizations/localization.dart';

enum ErrorType { unimplemented, unknown }

class AppError extends Error {
  final String message;
  final ErrorType type;

  AppError({required this.message, this.type = ErrorType.unknown});

  @override
  String toString() => 'AppError{message: $message, type: $type}';

  String toLocalizedMessage(AppLocalizations localizations) {
    return switch (type) {
      ErrorType.unimplemented => localizations.errorUnimplemented,
      ErrorType.unknown => localizations.errorUnknown,
    };
  }
}
