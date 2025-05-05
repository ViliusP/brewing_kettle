import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/ui/screens/not_found_404/starry_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFound404Screen extends StatelessWidget {
  const NotFound404Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    final MaterialTheme materialTheme = MaterialTheme(AppDefaults.font.name);
    final ThemeData theme = materialTheme.theme(AppTheme.dark.colorScheme);

    return Theme(
      data: theme,
      child: Builder(
        builder: (innerContext) {
          return StarryBackground(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "404",
                  style: TextTheme.of(
                    innerContext,
                  ).displayLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 160, height: 0.9),
                  textAlign: TextAlign.center,
                ),

                Text(
                  localizations.notFoundText,
                  style: TextTheme.of(
                    innerContext,
                  ).displayLarge?.copyWith(fontWeight: FontWeight.w700, fontSize: 80, height: 0.9),
                  textAlign: TextAlign.center,
                ),

                const Padding(padding: EdgeInsets.symmetric(vertical: 16)),

                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(300, 75),
                    iconSize: 44,
                    textStyle: TextTheme.of(
                      innerContext,
                    ).labelLarge?.copyWith(fontSize: 30, height: 1),
                  ),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  icon: const Icon(AppConstants.backIcon),
                  label: Text(localizations.generalGoBack),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
