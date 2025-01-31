import 'package:intl/intl.dart' as intl;

import 'localization.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

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
}
