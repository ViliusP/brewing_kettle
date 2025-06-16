import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/core/data/models/common/temperature_scale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

/// This file contains the general constants used in the app.
class AppConstants {
  const AppConstants._();

  static const String appName = "Virtinis Dashboard";
  static const String homepageUrl = "https://github.com/viliusp/virtinis_brewkettle";
  static const String repositoryUrl = "https://github.com/viliusp/virtinis_brewkettle";

  // System-specific maximum PID values
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

  /// Default value for temperature scale.
  static const TemperatureScale temperatureScale = TemperatureScale.celsius;
}
