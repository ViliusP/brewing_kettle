import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/locale/locale_store.dart';
import 'package:brew_kettle_dashboard/stores/theme/theme_store.dart';
import 'package:brew_kettle_dashboard/ui/common/flags/country_flag.dart';
import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:brew_kettle_dashboard/ui/screens/settings/language_select_dialog.dart';
import 'package:brew_kettle_dashboard/ui/screens/settings/theme_select_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

class ButtonsRow extends StatelessWidget {
  final LocaleStore localeStore = getIt<LocaleStore>();
  final ThemeStore themeStore = getIt<ThemeStore>();

  ButtonsRow({super.key});

  Future<void> _languageSelectDialogBuidlder(BuildContext context) async {
    LocaleStore localeStore = getIt<LocaleStore>();

    Locale? returnedValue = await showDialog<Locale>(
      context: context,
      builder: (BuildContext context) => LanguageSelectDialog(currentLocale: localeStore.locale),
    );

    if (returnedValue != null) localeStore.changeLocale(returnedValue);
  }

  Future<void> _themeSelectDialogBuilder(BuildContext context) async {
    ThemeStore themeStore = getIt<ThemeStore>();

    AppThemeMode? returnedValue = await showDialog<AppThemeMode>(
      context: context,
      builder: (BuildContext context) => ThemeSelectDialog(currentThemeMode: themeStore.themeMode),
    );

    if (returnedValue != null) themeStore.changeThemeMode(returnedValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return AnimatedSize(
      duration: Durations.short1,
      curve: Curves.easeOut,
      child: Card.outlined(
        shape: StadiumBorder(side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                clipBehavior: Clip.hardEdge,
                icon: Observer(
                  builder: (context) {
                    return SizedBox(
                      height: 14,
                      child: CountryFlag(
                        code: CountryCode.fromLanguageCode(localeStore.locale.languageCode),
                      ),
                    );
                  },
                ),
                onPressed: () => _languageSelectDialogBuidlder(context),
                label: Text(localizations.settingsLanguage),
              ),
              TextButton.icon(
                icon: Icon(switch (themeStore.theme.isLight) {
                  true => MdiIcons.weatherSunny,
                  false => MdiIcons.weatherNight,
                }),
                onPressed: () => _themeSelectDialogBuilder(context),
                label: Text(localizations.settingsTheme),
              ),
              TextButton.icon(
                onPressed: () {
                  GoRouter.of(context).pushNamed(AppRoute.information.name);
                },
                label: Text("Info"),
                icon: Icon(MdiIcons.informationOutline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
