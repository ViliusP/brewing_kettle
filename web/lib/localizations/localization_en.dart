import 'package:intl/intl.dart' as intl;

import 'localization.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get pageHomeTitle => 'Recipes';

  @override
  String get pageHomeDrawerHeader => 'Recipes';

  @override
  String get pageHomeDrawerListTileSettings => 'Settings';

  @override
  String pageHomeRecipeAuthor(String name) {
    return 'by $name';
  }

  @override
  String pageHomeRecipeCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'created $dateString';
  }

  @override
  String pageHomeRecipeVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votes',
      one: '$count vote',
    );
    return '$_temp0';
  }

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
}
