import 'package:brew_kettle_dashboard/constants/theme.dart';

/// This file contains the general constants used in the app.
class AppConstants {
  AppConstants._();

  static const String appName = "Brew Kettle Dashboard";
  static const String font = "Roboto";

  // System-specific maximum values (adjust based on your requirements)
  static const double maxProportional = 100.0;
  static const double maxIntegral = 50.0;
  static const double maxDerivative = 50.0;
}

class AppDefaults {
  AppDefaults._();

  static const AppFontFamily font = AppFontFamily.nunitoSans;
  static const AppTheme theme = AppTheme.light;
}
