import 'package:intl/intl.dart' as intl;

import 'localization.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
}
