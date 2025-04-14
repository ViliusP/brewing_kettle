import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/app_configuration/app_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/locale/locale_store.dart';
import 'package:brew_kettle_dashboard/stores/theme/theme_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/common/application_info/application_info.dart';
import 'package:brew_kettle_dashboard/ui/common/flags/country_flag.dart';
import 'package:brew_kettle_dashboard/ui/screens/settings/language_select_dialog.dart';
import 'package:brew_kettle_dashboard/ui/screens/settings/theme_select_dialog.dart';
import 'package:brew_kettle_dashboard/utils/textstyle_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class SettingsScreen extends StatelessWidget {
  final WebSocketConnectionStore _wsConnectionStore = getIt<WebSocketConnectionStore>();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        constraints: BoxConstraints(maxWidth: 816),
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // ---- TITLE ----
                  Row(
                    children: [
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: OutlinedButton.icon(
                          onPressed: _wsConnectionStore.close,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.secondary,
                            iconColor: colorScheme.secondary,
                            iconSize: 22,
                            textStyle: TextStyle(fontSize: 16),
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          label: Text(localizations.generalLogout),
                          icon: Icon(MdiIcons.logoutVariant),
                        ),
                      ),
                    ],
                  ),
                  _GeneralSection(),
                  // ---- GENERAL SETTINGS ----
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  // ---- BOTTOM ----
                  _ApplicationInfoSection(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A section that contains general settings options.
/// The section includes options for changing the language, theme, and advanced mode.
/// The section is displayed as a card with a title and a list of settings buttons.
///
/// Example usage:
/// ```dart
/// _SettingsSection()
/// ```
class _GeneralSection extends StatelessWidget {
  _GeneralSection();

  final LocaleStore _localeStore = getIt<LocaleStore>();
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final AppConfigurationStore _appConfigurationStore = getIt<AppConfigurationStore>();

  Future<void> _languageSelectDialogBuidlder(BuildContext context) async {
    LocaleStore localeStore = getIt<LocaleStore>();

    Locale? returnedValue = await showDialog<Locale>(
      context: context,
      builder: (BuildContext context) => LanguageSelectDialog(currentLocale: localeStore.locale),
    );

    if (returnedValue != null) localeStore.changeLanguage(returnedValue);
  }

  Future<void> _themeSelectDialogBuilder(BuildContext context) async {
    ThemeStore themeStore = getIt<ThemeStore>();

    AppTheme? returnedValue = await showDialog<AppTheme>(
      context: context,
      builder: (BuildContext context) => ThemeSelectDialog(currentTheme: themeStore.theme),
    );

    if (returnedValue != null) themeStore.changeTheme(returnedValue);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return _SettingsCard(
      title: localizations.pSettingsSectionGeneralTitle,
      child: Column(
        children: [
          _SettingsButton(
            icon: Icon(MdiIcons.earth),
            trailing: SizedBox(
              height: 20,
              child: Observer(
                builder:
                    (context) => CountryFlag(
                      code: CountryCode.fromLanguageCode(_localeStore.locale.languageCode),
                    ),
              ),
            ),
            onTap: () => _languageSelectDialogBuidlder(context),
            child: Text(localizations.pSettingsLanguage),
          ),
          _SettingsButton(
            icon: Icon(MdiIcons.palette),
            trailing: Observer(
              builder: (context) => Text(localizations.pSettingsThemeNames(_themeStore.theme.name)),
            ),
            onTap: () => _themeSelectDialogBuilder(context),
            child: Text(localizations.pSettingsTheme),
          ),
          _SettingsButton(
            icon: Icon(MdiIcons.tools),
            tooltip: "Turns on some debugging features",
            trailing: Observer(
              builder:
                  (context) => Checkbox(
                    value: _appConfigurationStore.isAdvancedMode,
                    onChanged: (value) {
                      if (value != null) {
                        _appConfigurationStore.setAdvancedMode(value);
                      }
                    },
                  ),
            ),
            onTap: () {
              _appConfigurationStore.setAdvancedMode(!_appConfigurationStore.isAdvancedMode);
            },
            child: Text("Advanced mode (TODO: localize)"),
          ),
        ],
      ),
    );
  }
}

/// A card that contains a [title] and a [child] widget.
/// The card has a rounded rectangle shape and an elevation effect.
/// The title is displayed at the top of the card and the child widget is displayed below it.
/// Example usage:
/// ```dart
/// _SettingsCard(
///   title: 'Settings',
///   child: Column(
///     children: [
///       Text('Setting 1'),
///       Text('Setting 2'),
///     ],
///   ),
/// )
class _SettingsCard extends StatelessWidget {
  final Widget child;

  final String title;

  const _SettingsCard({required this.title, required this.child});

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
              child: Text(title, style: textTheme.displaySmall, textAlign: TextAlign.left),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// A button that displays a child widget and an optional [icon] and [trailing] widget.
///
/// The button has a rounded rectangle shape and an elevation effect.
/// The button has an [onTap] callback that is triggered when the button is pressed.
/// The button also has an overlay color effect when pressed, hovered, or focused.
/// Example usage:
/// ```dart
/// _SettingsButton(
///   child: Text('Settings'),
///   icon: Icon(Icons.settings),
///   trailing: Icon(Icons.arrow_forward),
///   onTap: () {
///     // Do something when the button is pressed
///   },
/// )
/// ```
class _SettingsButton extends StatelessWidget {
  final Widget child;
  final Widget? icon;
  final Widget? trailing;
  final String? tooltip;
  final GestureTapCallback? onTap;

  const _SettingsButton({this.onTap, this.trailing, required this.child, this.icon, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = TextTheme.of(context);

    return Tooltip(
      message: tooltip,
      richMessage: tooltip == null ? const TextSpan(text: null) : null,
      child: Card.outlined(
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                if (icon != null) icon!,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: DefaultTextStyle(style: textTheme.bodyLarge ?? TextStyle(), child: child),
                ),
                Spacer(),
                if (trailing != null)
                  DefaultTextStyle(
                    style: (textTheme.bodyMedium ?? TextStyle()).changeWeight(FontWeight.w700),
                    child: trailing!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationInfoSection extends StatelessWidget {
  const _ApplicationInfoSection();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = TextTheme.of(context);
    TextStyle? textStyle = textTheme.labelMedium;

    ApplicationInfo? appInfo = ApplicationInfo.maybeOf(context);
    String packageName = appInfo?.packageName ?? '';
    String version = appInfo?.version ?? '';
    if (appInfo?.buildNumber != null) {
      version += '(${appInfo?.buildNumber})';
    }

    return Column(children: [Text(packageName, style: textStyle), Text(version, style: textStyle)]);
  }
}
