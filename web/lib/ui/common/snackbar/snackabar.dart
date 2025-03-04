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

  String localizedTitle(BuildContext context) {
    return switch (this) {
      _AppSnackBarType.error => AppLocalizations.of(context)!.generalError,
      _AppSnackBarType.info => AppLocalizations.of(context)!.generalInfo,
      _AppSnackBarType.success => AppLocalizations.of(context)!.generalSuccess,
      _AppSnackBarType.warning => AppLocalizations.of(context)!.generalWarning,
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
      title: Text(type.localizedTitle(context)),
      description: Text(message),
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
    ;
  }
}
