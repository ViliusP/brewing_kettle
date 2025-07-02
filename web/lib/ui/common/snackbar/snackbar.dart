import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:toastification/toastification.dart';

enum _AppSnackBarType {
  error(MdiIcons.exclamationThick, ToastificationType.error),
  info(MdiIcons.informationSlabCircleOutline, ToastificationType.info),
  success(MdiIcons.checkDecagramOutline, ToastificationType.success),
  warning(MdiIcons.alertCircleOutline, ToastificationType.warning);

  const _AppSnackBarType(this.icon, this.toastType);

  final IconData icon;
  final ToastificationType toastType;

  String localizedTitle(AppLocalizations localizations) {
    return switch (this) {
      _AppSnackBarType.error => localizations.generalError,
      _AppSnackBarType.info => localizations.generalInfo,
      _AppSnackBarType.success => localizations.generalSuccess,
      _AppSnackBarType.warning => localizations.generalWarning,
    };
  }
}

class AppSnackabar {
  static void error(BuildContext context, String message) {
    _show(context, message: message, type: _AppSnackBarType.error);
  }

  static void info(BuildContext context, String message) {
    _show(context, message: message, type: _AppSnackBarType.info);
  }

  static void warning(BuildContext context, String message) {
    _show(context, message: message, type: _AppSnackBarType.warning);
  }

  static void success(BuildContext context, String message) {
    _show(context, message: message, type: _AppSnackBarType.success);
  }

  static void _show(
    BuildContext context, {
    required String message,
    required _AppSnackBarType type,
  }) {
    Toastification().show(
      context: context,
      title: Text(type.localizedTitle(AppLocalizations.of(context)!)),
      description: SelectableText(message),
      type: type.toastType,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.bottomCenter,
      showProgressBar: false,
      borderRadius: BorderRadius.circular(12.0),
      closeButton: ToastCloseButton(
        buttonBuilder: (context, onClose) {
          return IconButton(
            onPressed: onClose,
            icon: Icon(MdiIcons.close),
            iconSize: 18,
            padding: EdgeInsets.all(4),
            constraints: BoxConstraints.tightFor(width: 30, height: 30),
            alignment: Alignment.center,
          );
        },
      ),
    );
  }
}
