import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'localization_en.dart';
import 'localization_lt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localizations/localization.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('lt')
  ];

  /// No description provided for @generalIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get generalIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// General label for date information.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get generalDate;

  /// General label for temperature readings.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get generalTemperature;

  /// General label for the desired or target temperature.
  ///
  /// In en, this message translates to:
  /// **'Target temperature'**
  String get generalTargetTemperature;

  /// General label for power consumption or output.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get generalPower;

  /// General label for error, for example used in toast messages.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get generalError;

  /// General label for info, for example used in toast messages.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get generalInfo;

  /// General label for success, for example used in toast messages.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get generalSuccess;

  /// General label for warning, for example used in toast messages.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get generalWarning;

  /// General label for version, for example used in about page.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get generalVersion;

  /// No description provided for @exceptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get exceptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// Message of unexpected error.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred.'**
  String get exceptionUnknown;

  /// Generic device connection fail exception.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to device.'**
  String get exceptionFailedToConnectToDevice;

  /// Exception message when timeout happened when connecting to device.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to the device. Please check device or provided address'**
  String get exceptionDeviceConnectionTimeout;

  /// Exception message when provided address is not valid and cannot be looked up.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to device. Bad address provided for kettle device.'**
  String get exceptionAddressLookupFailed;

  /// Exception message when provided address is partly good, but refuse to establish connection.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to device. Device refused connection. Please check your provided address.'**
  String get exceptionConnectionRefused;

  /// Exception message when timeout happened when connecting to server.
  ///
  /// In en, this message translates to:
  /// **'Request to device\'s server timed out. Please check your internet connection.'**
  String get exceptionHttpConnectionTimeout;

  /// Exception message when timeout happened when connecting to server.
  ///
  /// In en, this message translates to:
  /// **'Request to device\'s server timed out. Please check your internet connection.'**
  String get exceptionHttpSendTimeout;

  /// Exception message when timeout happened when connecting to server.
  ///
  /// In en, this message translates to:
  /// **'Request to device\'s server timed out. Please check your internet connection.'**
  String get exceptionHttpReceiveTimeout;

  /// Exception message when bad certificate is provided for server.
  ///
  /// In en, this message translates to:
  /// **'Request failed. Bad certificate provided for device\'s server. This should not happen.'**
  String get exceptionHttpBadCertificate;

  /// Exception message when bad response is received from server.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response ({code}). Request failed. This should not happen.'**
  String exceptionHttpBadResponse(String code);

  /// Exception message when request was cancelled.
  ///
  /// In en, this message translates to:
  /// **'Request was cancelled. This should not happenn.'**
  String get exceptionHttpCancel;

  /// Exception message when connection error happened.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to device\'s server. Please check your internet connection.'**
  String get exceptionHttpConnectionError;

  /// Exception message when unexpected error happened.
  ///
  /// In en, this message translates to:
  /// **'Unexpected network error occurred. There may be a problem with your internet connection or device\'s server.'**
  String get exceptionHttpUnknown;

  /// No description provided for @mainscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get mainscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// No description provided for @pMainGraphInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Temparature and power graph'**
  String get pMainGraphInfoTitle;

  /// Information text displayed on the main graph screen.
  ///
  /// In en, this message translates to:
  /// **'Shows heater data of every {seconds} {seconds, plural, =1{second} other{seconds}} for {hours} {hours, plural, =1{hour} other{hours}}.\nTap on graph points to see concrete values for that time.'**
  String pMainGraphInfoText(int seconds, num hours);

  /// No description provided for @pMainGraphInfoLegend.
  ///
  /// In en, this message translates to:
  /// **'Line legends'**
  String get pMainGraphInfoLegend;

  /// No description provided for @devicesScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get devicesScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// Title for communication controller in devices screen
  ///
  /// In en, this message translates to:
  /// **'Communication controller'**
  String get devicesCommunicationController;

  /// Secure version label in in devices screen
  ///
  /// In en, this message translates to:
  /// **'Secure version'**
  String get devicesSecureVersion;

  /// Compile time label in in devices screen
  ///
  /// In en, this message translates to:
  /// **'Compile time'**
  String get devicesCompileTime;

  /// Device screenshot label in communication controller section
  ///
  /// In en, this message translates to:
  /// **'Device screenshot'**
  String get devicesScreenshot;

  /// Tooltip for refresh screenshot button
  ///
  /// In en, this message translates to:
  /// **'Refresh screenshot'**
  String get devicesScreenshotRefreshTooltip;

  /// Communication log label in communication controller section
  ///
  /// In en, this message translates to:
  /// **'Communication log'**
  String get devicesCommunicationLog;

  /// Tooltip for show more log messages button
  ///
  /// In en, this message translates to:
  /// **'Show all log messages'**
  String get devicesShowMoreLogTooltip;

  /// Title for heater controller in devices screen
  ///
  /// In en, this message translates to:
  /// **'Heater controller'**
  String get devicesHeaterController;

  /// Title for PID in heater controller section
  ///
  /// In en, this message translates to:
  /// **'PID'**
  String get devicesPid;

  /// Label for proportional gain in PID form
  ///
  /// In en, this message translates to:
  /// **'Proportional gain'**
  String get devicesPidProportionalGain;

  /// Label for integral gain in PID form
  ///
  /// In en, this message translates to:
  /// **'Integral gain'**
  String get devicesPidIntegralGain;

  /// Label for derivative gain in PID form
  ///
  /// In en, this message translates to:
  /// **'Derivative gain'**
  String get devicesPidDerivativeGain;

  /// No description provided for @settingsscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get settingsscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// Title for settings page, show at top of the page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get pSettingsTitle;

  /// Title for general section at settings page
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get pSettingsSectionGeneralTitle;

  /// Setting name for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get pSettingsLanguage;

  /// Title for language select dialog, showed at top of component
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get cLanguageSelectDialogTitle;

  /// No description provided for @pSettingsInputLanguage.
  ///
  /// In en, this message translates to:
  /// **'{locale, select, lt {Lithuanian} en {English} lv {Latvian} other {unknown}}'**
  String pSettingsInputLanguage(String locale);

  /// Setting name for the current theme change
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get pSettingsTheme;

  /// Title for theme select dialog, showed at top of component
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get cThemeSelectDialogTitle;

  /// Names for all available themes in application
  ///
  /// In en, this message translates to:
  /// **'{theme, select, light {Light} lightMediumContrast {Light - medium contrast} lightHighContrast {Light - high contrast} dark {Dark} darkMediumContrast {Dark - medium contrast} darkHighContrast {Dark - high contrast} other {unknown}}'**
  String pSettingsThemeNames(String theme);

  /// No description provided for @layoutIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get layoutIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// Title for home item in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get layoutItemHome;

  /// Title for devivces item in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get layoutItemDevices;

  /// Title for settings item in navigation bar
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get layoutItemSettings;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'lt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'lt': return AppLocalizationsLt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
