import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:flutter/material.dart';

class ThemeSelectDialog extends StatelessWidget {
  final AppThemeMode? currentThemeMode;

  const ThemeSelectDialog({super.key, this.currentThemeMode});

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
              AppThemeMode.values
                  .map(
                    (theme) => RadioListTile<AppThemeMode>(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                      title: Text(localizations.settingsThemeNames(theme.name)),
                      value: theme,
                      groupValue: currentThemeMode,
                      onChanged: (AppThemeMode? value) => Navigator.of(context).pop(value),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
