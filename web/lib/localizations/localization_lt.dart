// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localization.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get generalIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get generalDate => 'Data';

  @override
  String get generalTemperature => 'Temperatūra';

  @override
  String get generalTargetTemperature => 'Tikslo temperatūra';

  @override
  String get generalPower => 'Galia';

  @override
  String get generalError => 'Klaida';

  @override
  String get generalInfo => 'Informacija';

  @override
  String get generalSuccess => 'Įvykdyta';

  @override
  String get generalWarning => 'Įspėjimas';

  @override
  String get generalVersion => 'Versija';

  @override
  String get generalSave => 'Išsaugoti';

  @override
  String get generalChange => 'Pakeisti';

  @override
  String get generalLogout => 'Atsijungti';

  @override
  String get generalExit => 'Išeiti';

  @override
  String get generalGoBack => 'Grįžti Atgal';

  @override
  String get formValidationRequired => 'Šis laukelis privalomas';

  @override
  String get formValidationMustBePositive => 'Šiame laukelyje turi būti teigiamas skaičius';

  @override
  String get formValidationMustBeNumber => 'Šiame laukelyje turi būti skaičius';

  @override
  String formValidationMustBeGreaterThan(String value) {
    return 'Reikšmė turi būti didesnė nei $value';
  }

  @override
  String formValidationMustBeNotGreaterThan(String value) {
    return 'Reikšmė turi būti ne didesnė nei $value';
  }

  @override
  String formValidationMustBeLessThan(String value) {
    return 'Reikšmė turi būti mažesnė nei $value';
  }

  @override
  String formValidationMustBeNotLessThan(String value) {
    return 'Reikšmė turi būti ne mažesnė nei $value';
  }

  @override
  String temperatureUnit(String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'celsius': 'Celsijus',
      'fahrenheit': 'Farenheitas',
      'kelvin': 'Kelvinas',
      'other': 'Unknown',
    });
    return '$_temp0';
  }

  @override
  String get exceptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get exceptionUnknown => 'Įvyko nežinoma klaida.';

  @override
  String get exceptionFailedToConnectToDevice => 'Nepavyko prisijungti prie įrenginio.';

  @override
  String get exceptionDeviceConnectionTimeout =>
      'Nepavyko prisijungti prie įrenginio. Patikrinkite įrenginį ar pateiktą adresą.';

  @override
  String get exceptionAddressLookupFailed =>
      'Nepavyko prisijungti prie įrenginio. Patikrinkite interneto ryšį ar pateiktą įrenginio adresą.';

  @override
  String get exceptionConnectionRefused =>
      'Nepavyko prisijungti prie įrenginio. Patikrinkite pateiktą įrenginio adresą.';

  @override
  String get exceptionHttpConnectionTimeout =>
      'Laikas užklausai į įrenginio serverį baigėsi. Patikrinkite tinklo ryšį.';

  @override
  String get exceptionHttpSendTimeout =>
      'Laikas užklausai į įrenginio serverį baigėsi. Patikrinkite tinklo ryšį.';

  @override
  String get exceptionHttpReceiveTimeout =>
      'Laikas užklausai gauti iš įrenginio serverio baigėsi. Patikrinkite tinklo ryšį.';

  @override
  String get exceptionHttpBadCertificate =>
      'Užklausa nepavyko. Blogas sertifikatas buvo pateiktas serveriui. Ši klaida neturėjo nutikti. Apie tai praneškite programinės įrangos kurėjams.';

  @override
  String exceptionHttpBadResponse(String code) {
    return 'Netikėtas atsakas iš įrenginio serverio ($code). Užklausa nepavyko. Ši klaida neturėjo nutikti. Apie tai praneškite programinės įrangos kurėjams.';
  }

  @override
  String get exceptionHttpCancel =>
      'Užklausa buvo atšaukta. Ši klaida neturėjo nutikti. Apie tai praneškite programinės įrangos kurėjams.';

  @override
  String get exceptionHttpConnectionError =>
      'Nepavyko prisijungti prie įrenginio serverio. Patikrinkite tinklo ryšį.';

  @override
  String get exceptionHttpUnknown =>
      'Įvyko netikėta tinklo problema. Tai gali būti interneto ryšio arba įrenginio serverio sutrikimai.';

  @override
  String get mainscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get mainGraphInfoTitle => 'Temperatūros ir galios grafikas';

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
      hours,
      locale: localeName,
      other: 'valandų',
      one: 'valandos',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'sekundžių',
      one: 'sekundę',
    );
    return 'Grafike rodomi kaitintuvo duomenys $hoursString $_temp0, kas $secondsString $_temp1.\nSpausdami ant grafiko taškų, pamatysite detalesnius to laiko duomenis.';
  }

  @override
  String get mainGraphInfoLegend => 'Linijų legenda';

  @override
  String get heaterControlIncreaseTemperature => 'Padininti temperatūrą';

  @override
  String get heaterControlDecreaseTemperature => 'Sumažinti temperatūrą';

  @override
  String get heaterControlIncreasePower => 'Padidinti galią';

  @override
  String get heaterControlDecreasePower => 'Sumažinti galią';

  @override
  String get heaterControlCardLabelIdle => 'Ramybės būsena';

  @override
  String get heaterControlCardLabelAutotune => 'Automatinis PID derinimas';

  @override
  String get heaterControlCardLabelError => 'Įvyko klaida';

  @override
  String get heaterControlCardMessageError =>
      'Įvyko klaida virintuvo valdiklyje, pabandykite perkraukite valdiklius.';

  @override
  String get heaterControlCardLabelStatusUnknown => 'Statusas nežinomas';

  @override
  String get heaterControlCardMessageStatusUnknown =>
      'Įvyko klaida - virintuvo valdiklio būsena nežinoma, pabandykite perkrauti aplikaciją ir abu valdiklius.';

  @override
  String get heaterControlCardLabelConfiguring => 'Konfigūruojama...';

  @override
  String get heaterControlCardMessageConfiguring =>
      'Laukiama, kol bus sukonfigūruotas virintuvo valdiklis. Tai turėtų užtrukti kelias sekundes.';

  @override
  String heaterControlSelectButtonLabel(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'idle': 'Ramybės būsena',
      'heating_manual': 'Galia',
      'heating_pid': 'Temperatūra',
      'other': 'Nežinoma',
    });
    return '$_temp0';
  }

  @override
  String heaterControlSelectButtonTooltip(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'idle': 'ramybės būsena',
      'heating_manual': 'pastovi galia',
      'heating_pid': 'PID',
      'autotune_pid': 'automatinis derinimas',
      'null': 'nėra',
      'other': 'nežinoma',
    });
    return 'Kaitinimo būdas - $_temp0';
  }

  @override
  String get sliderContainerDragTooltip => 'Tempkite, kad pakeistumėte vertę';

  @override
  String get graphOptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get sessionStatisticsTitle => 'Sesijos statistika';

  @override
  String get sessionStatLowestTemperature => 'Žemiausia temperatūra';

  @override
  String get sessionStatHighestTemperature => 'Aukščiausia temperatūra';

  @override
  String get sessionStatAverageTemperature => 'Vidutinė temperatūra';

  @override
  String get sessionStatNonIdleAveragePower => 'Vidutinė galia (esant aktyviai veikimui)';

  @override
  String get sessionStatAveragePower => 'Vidutinė galia';

  @override
  String get sessionStatIdleTime => 'Ramybės laikas';

  @override
  String get sessionStatActiveTime => 'Aktyvaus veikimo laikas';

  @override
  String get sessionStatLessThanMinute => 'mažiau nei minutė';

  @override
  String get dataDurationSpanTitle => 'Duomenų apimtis';

  @override
  String get dataDurationSpanInfo => 'Rodomi duomenys paskutinių';

  @override
  String get dataAggregationTitle => 'Duomenų sujungimas';

  @override
  String dataAggregationInfo(String duration) {
    return 'Duomenys sujungiami $duration intervalu';
  }

  @override
  String get dataAggregationSwitchLabel => 'Sujungti duomenis';

  @override
  String get aggregationByPropertyTitle => 'Duomenų laukelių sujungimas';

  @override
  String aggregationField(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'default': 'Numatytas',
      'power': 'Galia',
      'current_temperature': 'Dabartinė temperatūra',
      'target_temperature': 'Tikslo temperatūra',
      'other': 'Nežinoma',
    });
    return '$_temp0';
  }

  @override
  String aggregationType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'mean': 'Vidurkis',
      'median': 'Mediana',
      'min': 'Minimali reikšmė',
      'max': 'Maksimali reikšmė',
      'sum': 'Suma',
      'first': 'Pirma reikšmė',
      'last': 'Paskutinė reikšmė',
      'other': 'Nežinoma',
    });
    return '$_temp0';
  }

  @override
  String get connectionScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get connectButtonLabel => 'Prisijungti';

  @override
  String get scanButtonLabel => 'Ieškoti';

  @override
  String get deviceIpAddressFormLabel => 'Įrenginio IP adresas';

  @override
  String deviceIpAddressFormHelper(String address) {
    return 'Pavyzdžiui: \"$address\"';
  }

  @override
  String get deviceIpFormValidationRequired => 'Įveskite IP adresą';

  @override
  String get devicesScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get devicesCommunicationController => 'Komunikacijos valdiklis';

  @override
  String get devicesSecureVersion => 'Saugi versija';

  @override
  String get devicesCompileTime => 'Kompiliavimo laikas';

  @override
  String get devicesScreenshot => 'Ekrano vaizdas';

  @override
  String get devicesScreenshotRefreshTooltip => 'Atnaujinti ekrano vaizdą';

  @override
  String get devicesCommunicationLog => 'Komunikacijos išrašas';

  @override
  String get devicesShowMoreLogTooltip => 'Rodyti visas žinutes';

  @override
  String get devicesHeaterController => 'Virintuvo valdiklis';

  @override
  String get devicesPid => 'PID reguliatorius';

  @override
  String get devicesPidProportionalGain => 'Perdavimo koeficientas';

  @override
  String get devicesPidIntegralGain => 'Integruojančios grandies laiko konstanta';

  @override
  String get devicesPidDerivativeGain => 'Diferencijuojančios grandies laiko konstanta';

  @override
  String devicesFormHelperText(String value) {
    return 'Maksimali galima reikšmė $value';
  }

  @override
  String get settingsscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get settingsTitle => 'Nustatymai';

  @override
  String get settingsSectionGeneralTitle => 'Bendri';

  @override
  String get settingsLanguage => 'Kalba';

  @override
  String get languageSelectDialogTitle => 'Pasirinkite kalbą';

  @override
  String settingsInputLanguage(String locale) {
    String _temp0 = intl.Intl.selectLogic(locale, {
      'lt': 'Lietuvių',
      'en': 'Anglų',
      'lv': 'Latvių',
      'other': 'nežinoma',
    });
    return '$_temp0';
  }

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSelectDialogTitle => 'Pasirinkite temą';

  @override
  String settingsThemeNames(String theme) {
    String _temp0 = intl.Intl.selectLogic(theme, {
      'light': 'Šviesi',
      'lightMediumContrast': 'Šviesi - vidutinio kontrasto',
      'lightHighContrast': 'Šviesi - didelio kontrasto',
      'dark': 'Tamsi',
      'darkMediumContrast': 'Tamsi - vidutinio kontrasto',
      'darkHighContrast': 'Tamsi - didelio kontrasto',
      'system': 'Pagal įrenginio temą',
      'other': 'Nežinoma tema',
    });
    return '$_temp0';
  }

  @override
  String get settingsAdvancedMode => 'Išplėstinė režimas';

  @override
  String get settingsAdvancedModeTooltip =>
      'Įjungus bus pasiekiamas funkcionalumas, skirtas programos derinimui ir testavimui.';

  @override
  String get layoutIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get layoutItemHome => 'Pagrindinis';

  @override
  String get layoutItemDevices => 'Įrenginiai';

  @override
  String get layoutItemSettings => 'Nustatymai';

  @override
  String get temperatureScaleSettingTitle => 'Temperatūros skalė';

  @override
  String get temperatureScaleDialogTitle => 'Pasirinkite temperatūros skalę';

  @override
  String get errorScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get notFoundText => 'Puslapis nerastas';

  @override
  String get infoScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII =>
      '----------------------------------------------------';

  @override
  String get infoScreenTitle => 'Informacija';

  @override
  String get aboutTitle => 'Apie';

  @override
  String get faqTitle => 'Dažniausiai užduodami klausimai';

  @override
  String get faqQuestion1 => 'Klausimas 1: Aliquam eget sagittis nisl, id congue ipsum';

  @override
  String get faqAnswer1 =>
      'Atsakymas 1: Etiam faucibus velit ut tellus dapibus, vel lobortis elit consectetur';

  @override
  String get faqQuestion2 =>
      'Klausimas 2: Nulla leo velit, euismod eget dapibus sit amet, aliquet vitae turpis';

  @override
  String get faqAnswer2 => 'Atsakymas 2: Suspendisse hendrerit';

  @override
  String get faqQuestion3 => 'Klausimas 3: orci in maximus congue, metus mi tristique orci';

  @override
  String get faqAnswer3 => 'Atsakymas 3: id venenatis ante libero nec felis';

  @override
  String get faqQuestion4 => 'Klausimas 4: Aliquam ultricies massa ut porta tempor';

  @override
  String get faqAnswer4 => 'Atsakymas 4: Etiam suscipit diam vel urna interdum placerat';

  @override
  String get faqQuestion5 => 'Klausimas 5: Nullam id tempor nibh';

  @override
  String get faqAnswer5 => 'Atsakymas 5: Cras mollis odio fermentum magna efficitur';
}
