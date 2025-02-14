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
  String get generalTemperature => 'Temperatūra';

  @override
  String get generalTargetTemperature => 'Tikslo temperatūra';

  @override
  String get generalPower => 'Galia';

  @override
  String get mainscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get pMainGraphInfoTitle => 'Temperatūros ir galios grafikas';

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
      hours,
      locale: localeName,
      other: 'valandų',
      one: 'valandos',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'sekundžių',
      one: 'sekundę',
    );
    return 'Grafike rodomi kaitintuvo duomenys $hoursString $_temp0, kas $secondsString $_temp1.\nSpausdami ant grafiko taškų, pamatysite detalesnius to laiko duomenis.';
  }

  @override
  String get pMainGraphInfoLegend => 'Linijų legenda';

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
