import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:flutter/material.dart';

class ThemeSelectDialog extends StatelessWidget {
  final AppTheme? currentTheme;

  const ThemeSelectDialog({super.key, this.currentTheme});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(localizations.cThemeSelectDialogTitle),
      content: SizedBox(
        width: 260,
        child: ListView.builder(
          shrinkWrap: true,
          primary: false,
          itemCount: AppTheme.values.length,
          itemBuilder: (BuildContext context, int index) {
            AppTheme appTheme = AppTheme.values[index];
            print(appTheme.name);
            return ListTile(
              selected: currentTheme == appTheme,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              title: Text(localizations.pSettingsThemeNames(appTheme.name)),
              onTap: () => Navigator.of(context).pop(appTheme),
            );
          },
        ),
      ),
    );
  }
}
