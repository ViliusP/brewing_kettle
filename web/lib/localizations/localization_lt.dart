import 'package:intl/intl.dart' as intl;

import 'localization.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get generalIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get generalDate => 'Data';

  @override
  String get generalTemperature => 'Temperature';

  @override
  String get generalTargetTemperature => 'Target temperature';

  @override
  String get generalPower => 'Power';

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
    return 'Shows heater data of every $secondsString second$_temp0 for $hoursString hour$_temp1.\nTap on graph points to see concrete values for that time.';
  }

  @override
  String get pMainGraphInfoLegend => 'Line legends';

  @override
  String get settingsscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get pSettingsTitle => 'Nustatymai';

  @override
  String get pSettingsSectionGeneralTitle => 'Bendri';

  @override
  String get pSettingsLanguage => 'Kalba';

  @override
  String get cLanguageSelectDialogTitle => 'Pasirinkite kalbą';

  @override
  String pSettingsInputLanguage(String locale) {
    String _temp0 = intl.Intl.selectLogic(
      locale,
      {
        'lt': 'Lietuvių',
        'en': 'Anglų',
        'lv': 'Latvių',
        'other': 'nežinoma',
      },
    );
    return '$_temp0';
  }

  @override
  String get pSettingsTheme => 'Tema';

  @override
  String get cThemeSelectDialogTitle => 'Pasirinkite temą';

  @override
  String pSettingsThemeNames(String theme) {
    String _temp0 = intl.Intl.selectLogic(
      theme,
      {
        'light': 'Šviesi',
        'lightMediumContrast': 'Šviesi - vidutinio kontrasto',
        'lightHighContrast': 'Šviesi - didelio kontrasto',
        'dark': 'Tamsi',
        'darkMediumContrast': 'Tamsi - vidutinio kontrasto',
        'darkHighContrast': 'Tamsi - didelio kontrasto',
        'other': 'nežinoma tema',
      },
    );
    return '$_temp0';
  }

  @override
  String get layoutIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get layoutItemHome => 'Pagrindinis';

  @override
  String get layoutItemDevices => 'Įrenginiai';

  @override
  String get layoutItemSettings => 'Nustatymai';
}
