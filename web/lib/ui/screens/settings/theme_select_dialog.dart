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
      title: Text(localizations.themeSelectDialogTitle),
      content: SizedBox(
        width: 260,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              AppTheme.values
                  .map(
                    (theme) => RadioListTile<AppTheme>(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      title: Text(localizations.settingsThemeNames(theme.name)),
                      value: theme,
                      groupValue: currentTheme,
                      onChanged: (AppTheme? value) => Navigator.of(context).pop(value),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
