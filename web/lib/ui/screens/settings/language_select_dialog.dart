import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/ui/common/flags/country_flag.dart';
import 'package:flutter/material.dart';

class LanguageSelectDialog extends StatelessWidget {
  const LanguageSelectDialog({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> languageCodes = AppLocalizations.supportedLocales
        .map(
          (l) => l.languageCode,
        )
        .toList();

    return AlertDialog(
      title: const Text('Select language'),
      content: SizedBox(
        width: 260,
        child: ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: languageCodes.length,
          itemBuilder: (BuildContext context, int index) {
            CountryCode code = switch (languageCodes[index]) {
              "en" => CountryCode.gb,
              "lt" => CountryCode.lt,
              _ => CountryCode.lv,
            };

            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              leading: SizedBox(
                width: 30,
                child: CountryFlag(code: code),
              ),
              title: Text('Map'),
              onTap: () => Navigator.of(context).pop(),
            );
          },
        ),
      ),
    );
  }
}
