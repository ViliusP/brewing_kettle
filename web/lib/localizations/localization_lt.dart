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
  String get pSettingsTitle => 'Settings';

  @override
  String get pSettingsSectionGeneralTitle => 'General';

  @override
  String get cLanguageSelectDialogTitle => 'Select language';

  @override
  String pageSettingsInputLanguage(String locale) {
    String _temp0 = intl.Intl.selectLogic(
      locale,
      {
        'ar': 'عربي',
        'en': 'English',
        'es': 'Espa�ol',
        'other': '-',
      },
    );
    return '$_temp0';
  }
}
