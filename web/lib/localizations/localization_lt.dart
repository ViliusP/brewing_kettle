import 'package:intl/intl.dart' as intl;

import 'localization.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get pageHomeTitle => 'Recipes';

  @override
  String get pageHomeDrawerHeader => 'Recipes';

  @override
  String get pageHomeDrawerListTileSettings => 'Settings';

  @override
  String pageHomeRecipeAuthor(String name) {
    return 'por $name';
  }

  @override
  String pageHomeRecipeCreated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'creado $dateString';
  }

  @override
  String pageHomeRecipeVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count votos',
      one: '$count voto',
    );
    return '$_temp0';
  }

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
}
