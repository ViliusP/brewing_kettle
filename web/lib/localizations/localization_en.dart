// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localization.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get generalIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get generalDate => 'Date';

  @override
  String get generalTemperature => 'Temperature';

  @override
  String get generalTargetTemperature => 'Target temperature';

  @override
  String get generalPower => 'Power';

  @override
  String get generalError => 'Error';

  @override
  String get generalInfo => 'Info';

  @override
  String get generalSuccess => 'Success';

  @override
  String get generalWarning => 'Warning';

  @override
  String get generalVersion => 'Version';

  @override
  String get generalSave => 'Save';

  @override
  String get generalChange => 'Change';

  @override
  String get generalLogout => 'Logout';

  @override
  String get generalExit => 'Exit';

  @override
  String get generalGoBack => 'Go Back';

  @override
  String get formValidationRequired => 'This field is required';

  @override
  String get formValidationMustBePositive => 'This field must be positive';

  @override
  String get formValidationMustBeNumber => 'This field must be a number';

  @override
  String formValidationMustBeGreaterThan(String value) {
    return 'This field must be greater than $value';
  }

  @override
  String formValidationMustBeNotGreaterThan(String value) {
    return 'This field must be not greater than $value';
  }

  @override
  String formValidationMustBeLessThan(String value) {
    return 'This field must be less than $value';
  }

  @override
  String formValidationMustBeNotLessThan(String value) {
    return 'This field must be not less than $value';
  }

  @override
  String get exceptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get exceptionUnknown => 'Unknown error occurred.';

  @override
  String get exceptionFailedToConnectToDevice => 'Failed to connect to device.';

  @override
  String get exceptionDeviceConnectionTimeout =>
      'Failed to connect to the device. Please check device or provided address';

  @override
  String get exceptionAddressLookupFailed =>
      'Failed to connect to device. Bad address provided for kettle device.';

  @override
  String get exceptionConnectionRefused =>
      'Failed to connect to device. Device refused connection. Please check your provided address.';

  @override
  String get exceptionHttpConnectionTimeout =>
      'Request to device\'s server timed out. Please check your internet connection.';

  @override
  String get exceptionHttpSendTimeout =>
      'Request to device\'s server timed out. Please check your internet connection.';

  @override
  String get exceptionHttpReceiveTimeout =>
      'Request to device\'s server timed out. Please check your internet connection.';

  @override
  String get exceptionHttpBadCertificate =>
      'Request failed. Bad certificate provided for device\'s server. This should not happen.';

  @override
  String exceptionHttpBadResponse(String code) {
    return 'Unexpected response ($code). Request failed. This should not happen.';
  }

  @override
  String get exceptionHttpCancel => 'Request was cancelled. This should not happenn.';

  @override
  String get exceptionHttpConnectionError =>
      'Failed to connect to device\'s server. Please check your internet connection.';

  @override
  String get exceptionHttpUnknown =>
      'Unexpected network error occurred. There may be a problem with your internet connection or device\'s server.';

  @override
  String get mainscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get mainGraphInfoTitle => 'Temparature and power graph';

  @override
  String mainGraphInfoText(int seconds, num hours) {
    final intl.NumberFormat secondsNumberFormat = intl.NumberFormat.decimalPatternDigits(
      locale: localeName,
    );
    final String secondsString = secondsNumberFormat.format(seconds);
    final intl.NumberFormat hoursNumberFormat = intl.NumberFormat.decimalPatternDigits(
      locale: localeName,
    );
    final String hoursString = hoursNumberFormat.format(hours);

    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'seconds',
      one: 'second',
    );
    String _temp1 = intl.Intl.pluralLogic(hours, locale: localeName, other: 'hours', one: 'hour');
    return 'Shows heater data of every $secondsString $_temp0 for $hoursString $_temp1.\nTap on graph points to see concrete values for that time.';
  }

  @override
  String get mainGraphInfoLegend => 'Line legends';

  @override
  String get heaterControlIncreaseTemperature => 'Increase temperature';

  @override
  String get heaterControlDecreaseTemperature => 'Decrease temperature';

  @override
  String get heaterControlIncreasePower => 'Increase power';

  @override
  String get heaterControlDecreasePower => 'Decrease power';

  @override
  String get heaterControlCardLabelIdle => 'Idle';

  @override
  String get heaterControlCardLabelAutotune => 'Autotuning...';

  @override
  String get heaterControlCardLabelError => 'Error occurred';

  @override
  String get heaterControlCardMessageError =>
      'An error has occurred in the heater controller, try rebooting both controllers';

  @override
  String get heaterControlCardLabelStatusUnknown => 'Unknown status';

  @override
  String get heaterControlCardMessageStatusUnknown =>
      'An error occurred - the status of the boiler controller is unknown, try reloading the application and both controllers.';

  @override
  String get heaterControlCardLabelConfiguring => 'Configuring...';

  @override
  String get heaterControlCardMessageConfiguring =>
      'Waiting for the heater controller to be configured. This should take a few seconds.';

  @override
  String heaterControlSelectButtonLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'idle': 'Idle',
      'heating_manual': 'Power',
      'heating_pid': 'Temperature',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String heaterControlSelectButtonTooltip(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'idle': 'idle',
      'heating_manual': 'manual',
      'heating_pid': 'PID',
      'autotune_pid': 'autotune',
      'null': 'none',
      'other': 'unknown',
    });
    return 'Heating mode - $_temp0';
  }

  @override
  String get sliderContainerDragTooltip => 'Drag to change value';

  @override
  String get graphOptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get sessionStatisticsTitle => 'Session statistics';

  @override
  String get sessionStatLowestTemperature => 'Lowest temperature';

  @override
  String get sessionStatHighestTemperature => 'Highest temperature';

  @override
  String get sessionStatAverageTemperature => 'Average temperature';

  @override
  String get sessionStatNonIdleAveragePower => 'Average (non-idle) power';

  @override
  String get sessionStatAveragePower => 'Average power';

  @override
  String get sessionStatIdleTime => 'Idle time';

  @override
  String get sessionStatActiveTime => 'Active time';

  @override
  String get sessionStatLessThanMinute => 'less than a minute';

  @override
  String get dataDurationSpanTitle => 'Data duration span';

  @override
  String get dataDurationSpanInfo => 'Showing data for the last: ';

  @override
  String get dataAggregationTitle => 'Data aggregation';

  @override
  String dataAggregationInfo(String duration) {
    return 'Data is aggregated by interval of $duration';
  }

  @override
  String get dataAggregationSwitchLabel => 'Aggregate data';

  @override
  String get aggregationByPropertyTitle => 'Properties aggregation';

  @override
  String aggregationField(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'default': 'Default',
      'power': 'Power',
      'current_temperature': 'Current temperature',
      'target_temperature': 'Target temperature',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String aggregationType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mean': 'Mean',
      'median': 'Median',
      'min': 'Min',
      'max': 'Max',
      'sum': 'Sum',
      'first': 'First',
      'last': 'Last',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get connectionScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get connectButtonLabel => 'Connect';

  @override
  String get scanButtonLabel => 'Scan';

  @override
  String get deviceIpAddressFormLabel => 'Device IP address';

  @override
  String deviceIpAddressFormHelper(String address) {
    return 'For example: \"$address\"';
  }

  @override
  String get deviceIpFormValidationRequired => 'Please provide device IP';

  @override
  String get devicesScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get devicesCommunicationController => 'Communication controller';

  @override
  String get devicesSecureVersion => 'Secure version';

  @override
  String get devicesCompileTime => 'Compile time';

  @override
  String get devicesScreenshot => 'Device screenshot';

  @override
  String get devicesScreenshotRefreshTooltip => 'Refresh screenshot';

  @override
  String get devicesCommunicationLog => 'Communication log';

  @override
  String get devicesShowMoreLogTooltip => 'Show all log messages';

  @override
  String get devicesHeaterController => 'Heater controller';

  @override
  String get devicesPid => 'PID';

  @override
  String get devicesPidProportionalGain => 'Proportional gain';

  @override
  String get devicesPidIntegralGain => 'Integral gain';

  @override
  String get devicesPidDerivativeGain => 'Derivative gain';

  @override
  String devicesFormHelperText(String value) {
    return 'Maximum value is $value';
  }

  @override
  String get settingsscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneralTitle => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSelectDialogTitle => 'Select language';

  @override
  String settingsInputLanguage(String locale) {
    String _temp0 = intl.Intl.selectLogic(locale, {
      'lt': 'Lithuanian',
      'en': 'English',
      'lv': 'Latvian',
      'other': 'unknown',
    });
    return '$_temp0';
  }

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSelectDialogTitle => 'Select theme';

  @override
  String settingsThemeNames(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'light': 'Light',
      'lightMediumContrast': 'Light - medium contrast',
      'lightHighContrast': 'Light - high contrast',
      'dark': 'Dark',
      'darkMediumContrast': 'Dark - medium contrast',
      'darkHighContrast': 'Dark - high contrast',
      'system': 'Same as device\'s',
      'other': 'unknown',
    });
    return '$_temp0';
  }

  @override
  String get settingsAdvancedMode => 'Advanced mode';

  @override
  String get settingsAdvancedModeTooltip => 'Turns on some debugging features';

  @override
  String get layoutIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get layoutItemHome => 'Home';

  @override
  String get layoutItemDevices => 'Devices';

  @override
  String get layoutItemSettings => 'Settings';

  @override
  String get errorScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get notFoundText => 'Not found';

  @override
  String get infoScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get infoScreenTitle => 'Information';

  @override
  String get aboutTitle => 'About';

  @override
  String get faqTitle => 'Frequently asked questions';

  @override
  String get faqQuestion1 => 'Question 1: Lorem ipsum dolor sit amet, consectetur adipiscing elit';

  @override
  String get faqAnswer1 => 'Answer 1: Aliquam eget sagittis nisl, id congue ipsum';

  @override
  String get faqQuestion2 =>
      'Question 2: Etiam faucibus velit ut tellus dapibus, vel lobortis elit consectetur';

  @override
  String get faqAnswer2 =>
      'Answer 2: Nulla leo velit, euismod eget dapibus sit amet, aliquet vitae turpis';

  @override
  String get faqQuestion3 =>
      'Question 3: Suspendisse hendrerit, orci in maximus congue, metus mi tristique orci';

  @override
  String get faqAnswer3 => 'Answer 3: id venenatis ante libero nec felis';

  @override
  String get faqQuestion4 => 'Question 4: Aliquam ultricies massa ut porta tempor';

  @override
  String get faqAnswer4 => 'Answer 4: Etiam suscipit diam vel urna interdum placerat';

  @override
  String get faqQuestion5 => 'Question 5: Nullam id tempor nibh.';

  @override
  String get faqAnswer5 => 'Answer 5: Cras mollis odio fermentum magna efficitur';
}
