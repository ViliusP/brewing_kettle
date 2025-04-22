import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

/// This file contains the general constants used in the app.
class AppConstants {
  AppConstants._();

  static const String appName = "Brew Kettle Dashboard";

  // System-specific maximum values (adjust based on your requirements)
  static const double maxProportional = 100.0;
  static const double maxIntegral = 50.0;
  static const double maxDerivative = 50.0;

  static const IconData backIcon = MdiIcons.arrowLeft;
}

class AppDefaults {
  AppDefaults._();

  /// Default value for the font family.
  static const AppFontFamily font = AppFontFamily.nunitoSans;
  static const AppFontFamily monospaceFont = AppFontFamily.firaMono;

  /// Default value for theme.
  static const AppTheme theme = AppTheme.light;
  static const AppThemeMode themeMode = AppThemeMode.system;

  /// Default value for language.
  static const Locale locale = Locale('en');

  /// Default value for advanced mode.
  static const bool isAdvancedMode = false;
}
