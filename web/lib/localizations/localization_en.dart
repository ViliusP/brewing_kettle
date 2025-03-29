// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localization.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get generalIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get generalDate => 'Date';

  @override
  String get generalTemperature => 'Temperature';

  @override
  String get generalTargetTemperature => 'Target temperature';

  @override
  String get generalPower => 'Power';

  @override
  String get generalError => 'Error';

  @override
  String get generalInfo => 'Info';

  @override
  String get generalSuccess => 'Success';

  @override
  String get generalWarning => 'Warning';

  @override
  String get generalVersion => 'Version';

  @override
  String get generalSave => 'Save';

  @override
  String get generalChange => 'Change';

  @override
  String get exceptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get exceptionUnknown => 'Unknown error occurred.';

  @override
  String get exceptionFailedToConnectToDevice => 'Failed to connect to device.';

  @override
  String get exceptionDeviceConnectionTimeout => 'Failed to connect to the device. Please check device or provided address';

  @override
  String get exceptionAddressLookupFailed => 'Failed to connect to device. Bad address provided for kettle device.';

  @override
  String get exceptionConnectionRefused => 'Failed to connect to device. Device refused connection. Please check your provided address.';

  @override
  String get exceptionHttpConnectionTimeout => 'Request to device\'s server timed out. Please check your internet connection.';

  @override
  String get exceptionHttpSendTimeout => 'Request to device\'s server timed out. Please check your internet connection.';

  @override
  String get exceptionHttpReceiveTimeout => 'Request to device\'s server timed out. Please check your internet connection.';

  @override
  String get exceptionHttpBadCertificate => 'Request failed. Bad certificate provided for device\'s server. This should not happen.';

  @override
  String exceptionHttpBadResponse(String code) {
    return 'Unexpected response ($code). Request failed. This should not happen.';
  }

  @override
  String get exceptionHttpCancel => 'Request was cancelled. This should not happenn.';

  @override
  String get exceptionHttpConnectionError => 'Failed to connect to device\'s server. Please check your internet connection.';

  @override
  String get exceptionHttpUnknown => 'Unexpected network error occurred. There may be a problem with your internet connection or device\'s server.';

  @override
  String get mainscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get pMainGraphInfoTitle => 'Temparature and power graph';

  @override
  String pMainGraphInfoText(int seconds, num hours) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPatternDigits(
      locale: localeName,
      
    );
    final String secondsString = secondsNumberFormat.format(seconds);
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.decimalPatternDigits(
      locale: localeName,
      
    );
    final String hoursString = hoursNumberFormat.format(hours);

    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'seconds',
      one: 'second',
    );
    String _temp1 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'hours',
      one: 'hour',
    );
    return 'Shows heater data of every $secondsString $_temp0 for $hoursString $_temp1.\nTap on graph points to see concrete values for that time.';
  }

  @override
  String get pMainGraphInfoLegend => 'Line legends';

  @override
  String get devicesScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get devicesCommunicationController => 'Communication controller';

  @override
  String get devicesSecureVersion => 'Secure version';

  @override
  String get devicesCompileTime => 'Compile time';

  @override
  String get devicesScreenshot => 'Device screenshot';

  @override
  String get devicesScreenshotRefreshTooltip => 'Refresh screenshot';

  @override
  String get devicesCommunicationLog => 'Communication log';

  @override
  String get devicesShowMoreLogTooltip => 'Show all log messages';

  @override
  String get devicesHeaterController => 'Heater controller';

  @override
  String get devicesPid => 'PID';

  @override
  String get devicesPidProportionalGain => 'Proportional gain';

  @override
  String get devicesPidIntegralGain => 'Integral gain';

  @override
  String get devicesPidDerivativeGain => 'Derivative gain';

  @override
  String get settingsscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get pSettingsTitle => 'Settings';

  @override
  String get pSettingsSectionGeneralTitle => 'General';

  @override
  String get pSettingsLanguage => 'Language';

  @override
  String get cLanguageSelectDialogTitle => 'Select language';

  @override
  String pSettingsInputLanguage(String locale) {
    String _temp0 = intl.Intl.selectLogic(
      locale,
      {
        'lt': 'Lithuanian',
        'en': 'English',
        'lv': 'Latvian',
        'other': 'unknown',
      },
    );
    return '$_temp0';
  }

  @override
  String get pSettingsTheme => 'Theme';

  @override
  String get cThemeSelectDialogTitle => 'Select theme';

  @override
  String pSettingsThemeNames(String theme) {
    String _temp0 = intl.Intl.selectLogic(
      theme,
      {
        'light': 'Light',
        'lightMediumContrast': 'Light - medium contrast',
        'lightHighContrast': 'Light - high contrast',
        'dark': 'Dark',
        'darkMediumContrast': 'Dark - medium contrast',
        'darkHighContrast': 'Dark - high contrast',
        'other': 'unknown',
      },
    );
    return '$_temp0';
  }

  @override
  String get layoutIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get layoutItemHome => 'Home';

  @override
  String get layoutItemDevices => 'Devices';

  @override
  String get layoutItemSettings => 'Settings';
}
