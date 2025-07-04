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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('lt')];

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

  /// General label for save action, for example used in buttons.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get generalSave;

  /// General label for change action, for example used in buttons.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get generalChange;

  /// General label for logout action, for example used in buttons.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get generalLogout;

  /// General label for exit action, for example used in buttons.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get generalExit;

  /// General label going back to previous screen, for example used in buttons.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get generalGoBack;

  /// Validation error message when field is required
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get formValidationRequired;

  /// Validation error message when field must be positive.
  ///
  /// In en, this message translates to:
  /// **'This field must be positive'**
  String get formValidationMustBePositive;

  /// Validation error message when field must be a number.
  ///
  /// In en, this message translates to:
  /// **'This field must be a number'**
  String get formValidationMustBeNumber;

  /// Validation error message when field must be greater than {value}.
  ///
  /// In en, this message translates to:
  /// **'This field must be greater than {value}'**
  String formValidationMustBeGreaterThan(String value);

  /// Validation error message when field must be not greater than {value}.
  ///
  /// In en, this message translates to:
  /// **'This field must be not greater than {value}'**
  String formValidationMustBeNotGreaterThan(String value);

  /// Validation error message when field must be less than {value}.
  ///
  /// In en, this message translates to:
  /// **'This field must be less than {value}'**
  String formValidationMustBeLessThan(String value);

  /// Validation error message when field must be not less than {value}.
  ///
  /// In en, this message translates to:
  /// **'This field must be not less than {value}'**
  String formValidationMustBeNotLessThan(String value);

  /// Names for all available temperature units in application
  ///
  /// In en, this message translates to:
  /// **'{unit, select, celsius {Celsius} fahrenheit {Fahrenheit} kelvin {Kelvin} other {Unknown}}'**
  String temperatureUnit(String unit);

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

  /// No description provided for @mainGraphInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Temparature and power graph'**
  String get mainGraphInfoTitle;

  /// Information text displayed on the main graph screen.
  ///
  /// In en, this message translates to:
  /// **'Shows heater data of every {seconds} {seconds, plural, =1{second} other{seconds}} for {hours} {hours, plural, =1{hour} other{hours}}.\nTap on graph points to see concrete values for that time.'**
  String mainGraphInfoText(int seconds, num hours);

  /// Title for legend line section in graph info.
  ///
  /// In en, this message translates to:
  /// **'Line legends'**
  String get mainGraphInfoLegend;

  /// Label for increase temperature button
  ///
  /// In en, this message translates to:
  /// **'Increase temperature'**
  String get heaterControlIncreaseTemperature;

  /// LabTooltipel for decrease temperature button
  ///
  /// In en, this message translates to:
  /// **'Decrease temperature'**
  String get heaterControlDecreaseTemperature;

  /// Tooltip for increase power button
  ///
  /// In en, this message translates to:
  /// **'Increase power'**
  String get heaterControlIncreasePower;

  /// Tooltip for decrease power button
  ///
  /// In en, this message translates to:
  /// **'Decrease power'**
  String get heaterControlDecreasePower;

  /// Label for heater control card when heater is idle
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get heaterControlCardLabelIdle;

  /// Label for heater control card when heater is autotuning
  ///
  /// In en, this message translates to:
  /// **'Autotuning...'**
  String get heaterControlCardLabelAutotune;

  /// Label for heater control card when error occurred
  ///
  /// In en, this message translates to:
  /// **'Error occurred'**
  String get heaterControlCardLabelError;

  /// Message for heater control card when error occurred
  ///
  /// In en, this message translates to:
  /// **'An error has occurred in the heater controller, try rebooting both controllers'**
  String get heaterControlCardMessageError;

  /// Label for heater control card when status is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown status'**
  String get heaterControlCardLabelStatusUnknown;

  /// Message for heater control card when status is unknown
  ///
  /// In en, this message translates to:
  /// **'An error occurred - the status of the boiler controller is unknown, try reloading the application and both controllers.'**
  String get heaterControlCardMessageStatusUnknown;

  /// Label for heater control card when configuring
  ///
  /// In en, this message translates to:
  /// **'Configuring...'**
  String get heaterControlCardLabelConfiguring;

  /// Message for heater control card when configuring
  ///
  /// In en, this message translates to:
  /// **'Waiting for the heater controller to be configured. This should take a few seconds.'**
  String get heaterControlCardMessageConfiguring;

  /// Label for heater control select button
  ///
  /// In en, this message translates to:
  /// **'{mode, select, idle {Idle} heating_manual {Power} heating_pid {Temperature} other {Unknown}}'**
  String heaterControlSelectButtonLabel(String mode);

  /// Tooltip for heater control select button
  ///
  /// In en, this message translates to:
  /// **'Heating mode - {mode, select, idle {idle} heating_manual {manual} heating_pid {PID} autotune_pid {autotune} null {none} other {unknown}}'**
  String heaterControlSelectButtonTooltip(String mode);

  /// Tooltip for slider container when dragging
  ///
  /// In en, this message translates to:
  /// **'Drag to change value'**
  String get sliderContainerDragTooltip;

  /// No description provided for @graphOptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get graphOptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// Title for session statistics section in graph options
  ///
  /// In en, this message translates to:
  /// **'Session statistics'**
  String get sessionStatisticsTitle;

  /// Label for lowest temperature in session statistics
  ///
  /// In en, this message translates to:
  /// **'Lowest temperature'**
  String get sessionStatLowestTemperature;

  /// Label for highest temperature in session statistics
  ///
  /// In en, this message translates to:
  /// **'Highest temperature'**
  String get sessionStatHighestTemperature;

  /// Label for average temperature in session statistics
  ///
  /// In en, this message translates to:
  /// **'Average temperature'**
  String get sessionStatAverageTemperature;

  /// Label for average (non-idle) power in session statistics
  ///
  /// In en, this message translates to:
  /// **'Average (non-idle) power'**
  String get sessionStatNonIdleAveragePower;

  /// Label for average power in session statistics
  ///
  /// In en, this message translates to:
  /// **'Average power'**
  String get sessionStatAveragePower;

  /// Label for idle time in session statistics
  ///
  /// In en, this message translates to:
  /// **'Idle time'**
  String get sessionStatIdleTime;

  /// Label for active time in session statistics
  ///
  /// In en, this message translates to:
  /// **'Active time'**
  String get sessionStatActiveTime;

  /// Label for less than a minute in session statistics
  ///
  /// In en, this message translates to:
  /// **'less than a minute'**
  String get sessionStatLessThanMinute;

  /// Title for data duration span in graph options
  ///
  /// In en, this message translates to:
  /// **'Data duration span'**
  String get dataDurationSpanTitle;

  /// Information text for data duration span in graph options
  ///
  /// In en, this message translates to:
  /// **'Showing data for the last: '**
  String get dataDurationSpanInfo;

  /// Title for data aggregation in graph options
  ///
  /// In en, this message translates to:
  /// **'Data aggregation'**
  String get dataAggregationTitle;

  /// Information text for data aggregation in graph options
  ///
  /// In en, this message translates to:
  /// **'Data is aggregated by interval of {duration}'**
  String dataAggregationInfo(String duration);

  /// Label for data aggregation switch in graph options
  ///
  /// In en, this message translates to:
  /// **'Aggregate data'**
  String get dataAggregationSwitchLabel;

  /// Title for properties aggregation in graph options
  ///
  /// In en, this message translates to:
  /// **'Properties aggregation'**
  String get aggregationByPropertyTitle;

  /// Label for aggregation field selection
  ///
  /// In en, this message translates to:
  /// **'{field, select, default {Default} power {Power} current_temperature {Current temperature} target_temperature {Target temperature} other {Unknown}}'**
  String aggregationField(String field);

  /// Label for aggregation type selection
  ///
  /// In en, this message translates to:
  /// **'{type, select, mean {Mean} median {Median} min {Min} max {Max} sum {Sum} first {First} last {Last} default {Default} other {Unknown}}'**
  String aggregationType(String type);

  /// No description provided for @connectionScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get connectionScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// Label for connect button in connection screen
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connectButtonLabel;

  /// Label for scan button in connection screen
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanButtonLabel;

  /// Label for scan button in connection screen
  ///
  /// In en, this message translates to:
  /// **'Device IP address'**
  String get deviceIpAddressFormLabel;

  /// Helper text for device IP address form field
  ///
  /// In en, this message translates to:
  /// **'For example: \"{address}\"'**
  String deviceIpAddressFormHelper(String address);

  /// Validation error message when device IP field is empty
  ///
  /// In en, this message translates to:
  /// **'Please provide device IP'**
  String get deviceIpFormValidationRequired;

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

  /// Helper text for form field, shows maximum value
  ///
  /// In en, this message translates to:
  /// **'Maximum value is {value}'**
  String devicesFormHelperText(String value);

  /// No description provided for @settingsscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get settingsscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// Title for settings page, show at top of the page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title for general section at settings page
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsSectionGeneralTitle;

  /// Setting name for language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Title for language select dialog, showed at top of component
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get languageSelectDialogTitle;

  /// No description provided for @settingsInputLanguage.
  ///
  /// In en, this message translates to:
  /// **'{locale, select, lt {Lithuanian} en {English} lv {Latvian} other {unknown}}'**
  String settingsInputLanguage(String locale);

  /// Setting name for the current theme change
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Title for theme select dialog, showed at top of component
  ///
  /// In en, this message translates to:
  /// **'Select theme'**
  String get themeSelectDialogTitle;

  /// Names for all available themes in application
  ///
  /// In en, this message translates to:
  /// **'{theme, select, light {Light} lightMediumContrast {Light - medium contrast} lightHighContrast {Light - high contrast} dark {Dark} darkMediumContrast {Dark - medium contrast} darkHighContrast {Dark - high contrast} system {Same as device\'s} other {unknown}}'**
  String settingsThemeNames(String theme);

  /// Setting name for advanced mode
  ///
  /// In en, this message translates to:
  /// **'Advanced mode'**
  String get settingsAdvancedMode;

  /// Tooltip for advanced mode setting button
  ///
  /// In en, this message translates to:
  /// **'Turns on some debugging features'**
  String get settingsAdvancedModeTooltip;

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

  /// Title for temperature scale setting in settings screen
  ///
  /// In en, this message translates to:
  /// **'Temperature scale'**
  String get temperatureScaleSettingTitle;

  /// Title for temperature scale select dialog, showed at top of component
  ///
  /// In en, this message translates to:
  /// **'Select temperature scale'**
  String get temperatureScaleDialogTitle;

  /// No description provided for @errorScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get errorScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// Text for not found screen
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFoundText;

  /// No description provided for @infoScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII.
  ///
  /// In en, this message translates to:
  /// **'----------------------------------------------------'**
  String get infoScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII;

  /// Title for info screen
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get infoScreenTitle;

  /// Title for about section in info screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// Title for faq section in info screen
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get faqTitle;

  /// Question 1 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Question 1: Lorem ipsum dolor sit amet, consectetur adipiscing elit'**
  String get faqQuestion1;

  /// Answer 1 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Answer 1: Aliquam eget sagittis nisl, id congue ipsum'**
  String get faqAnswer1;

  /// Question 2 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Question 2: Etiam faucibus velit ut tellus dapibus, vel lobortis elit consectetur'**
  String get faqQuestion2;

  /// Answer 2 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Answer 2: Nulla leo velit, euismod eget dapibus sit amet, aliquet vitae turpis'**
  String get faqAnswer2;

  /// Question 3 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Question 3: Suspendisse hendrerit, orci in maximus congue, metus mi tristique orci'**
  String get faqQuestion3;

  /// Answer 3 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Answer 3: id venenatis ante libero nec felis'**
  String get faqAnswer3;

  /// Question 4 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Question 4: Aliquam ultricies massa ut porta tempor'**
  String get faqQuestion4;

  /// Answer 4 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Answer 4: Etiam suscipit diam vel urna interdum placerat'**
  String get faqAnswer4;

  /// Question 5 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Question 5: Nullam id tempor nibh.'**
  String get faqQuestion5;

  /// Answer 5 text in info screen
  ///
  /// In en, this message translates to:
  /// **'Answer 5: Cras mollis odio fermentum magna efficitur'**
  String get faqAnswer5;
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
    case 'en':
      return AppLocalizationsEn();
    case 'lt':
      return AppLocalizationsLt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
