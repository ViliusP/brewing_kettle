import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/ui/common/flags/country_flag.dart';
import 'package:flutter/material.dart';

class LanguageSelectDialog extends StatelessWidget {
  final Locale? currentLocale;

  const LanguageSelectDialog({super.key, this.currentLocale});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.cLanguageSelectDialogTitle),
      content: SizedBox(
        width: 260,
        child: ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: AppLocalizations.supportedLocales.length,
          itemBuilder: (BuildContext context, int index) {
            Locale locale = AppLocalizations.supportedLocales[index];
            CountryCode code = switch (locale.languageCode) {
              "en" => CountryCode.gb,
              "lt" => CountryCode.lt,
              _ => CountryCode.lv,
            };

            return ListTile(
              selected: currentLocale == locale,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              leading: SizedBox(
                width: 30,
                child: CountryFlag(code: code),
              ),
              title: Text(
                localizations.pSettingsInputLanguage(locale.languageCode),
              ),
              onTap: () => Navigator.of(context).pop(locale),
            );
          },
        ),
      ),
    );
  }
}
