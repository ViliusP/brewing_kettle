import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/locale/locale_store.dart';
import 'package:brew_kettle_dashboard/stores/theme/theme_store.dart';
import 'package:brew_kettle_dashboard/ui/common/flags/country_flag.dart';
import 'package:brew_kettle_dashboard/ui/screens/settings/language_select_dialog.dart';
import 'package:brew_kettle_dashboard/ui/screens/settings/theme_select_dialog.dart';
import 'package:brew_kettle_dashboard/utils/textstyle_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _languageSelectDialogBuidlder(BuildContext context) async {
    LocaleStore localeStore = getIt<LocaleStore>();

    Locale? returnedValue = await showDialog<Locale>(
      context: context,
      builder: (BuildContext context) =>
          LanguageSelectDialog(currentLocale: localeStore.locale),
    );

    if (returnedValue != null) localeStore.changeLanguage(returnedValue);
  }

  Future<void> _themeSelectDialogBuilder(BuildContext context) async {
    ThemeStore themeStore = getIt<ThemeStore>();

    AppTheme? returnedValue = await showDialog<AppTheme>(
      context: context,
      builder: (BuildContext context) => ThemeSelectDialog(
        currentTheme: themeStore.theme,
      ),
    );

    if (returnedValue != null) themeStore.changeTheme(returnedValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final LocaleStore localeStore = getIt<LocaleStore>();
    final ThemeStore themeStore = getIt<ThemeStore>();

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        constraints: BoxConstraints(maxWidth: 816),
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  SettingsCard(
                    title: localizations.pSettingsSectionGeneralTitle,
                    child: Column(
                      children: [
                        SettingsButton(
                          icon: Icon(MdiIcons.earth),
                          trailing: SizedBox(
                            height: 20,
                            child: Observer(
                              builder: (context) => CountryFlag(
                                code: CountryCode.fromLanguageCode(
                                  localeStore.locale.languageCode,
                                ),
                              ),
                            ),
                          ),
                          onTap: () => _languageSelectDialogBuidlder(context),
                          child: Text(localizations.pSettingsLanguage),
                        ),
                        SettingsButton(
                          icon: Icon(MdiIcons.palette),
                          trailing: Observer(
                            builder: (context) => Text(
                              localizations.pSettingsThemeNames(
                                themeStore.theme.name,
                              ),
                            ),
                          ),
                          onTap: () => _themeSelectDialogBuilder(context),
                          child: Text(localizations.pSettingsTheme),
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final Widget child;

  final String title;

  const SettingsCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = TextTheme.of(context);

    return Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
      surfaceTintColor: colorScheme.primaryFixedDim,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: textTheme.displaySmall,
                textAlign: TextAlign.left,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class SettingsButton extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final Widget? trailing;
  final GestureTapCallback? onTap;

  const SettingsButton({
    super.key,
    this.onTap,
    this.trailing,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = TextTheme.of(context);

    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withAlpha(26);
          }
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.primary.withAlpha(20);
          }
          if (states.contains(WidgetState.focused)) {
            return colorScheme.primary.withAlpha(26);
          }
          return null;
        }),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Row(
            children: [
              if (icon != null) icon!,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: DefaultTextStyle(
                  style: textTheme.bodyLarge ?? TextStyle(),
                  child: child,
                ),
              ),
              Spacer(),
              if (trailing != null)
                DefaultTextStyle(
                  style: (textTheme.bodyMedium ?? TextStyle()).changeWeight(
                    FontWeight.w700,
                  ),
                  child: trailing!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
