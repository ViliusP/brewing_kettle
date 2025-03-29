// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'localization.dart';

// ignore_for_file: type=lint

/// The translations for Lithuanian (`lt`).
class AppLocalizationsLt extends AppLocalizations {
  AppLocalizationsLt([String locale = 'lt']) : super(locale);

  @override
  String get generalIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

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
  String get exceptionsIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get exceptionUnknown => 'Įvyko nežinoma klaida.';

  @override
  String get exceptionFailedToConnectToDevice => 'Nepavyko prisijungti prie įrenginio.';

  @override
  String get exceptionDeviceConnectionTimeout => 'Nepavyko prisijungti prie įrenginio. Patikrinkite įrenginį ar pateiktą adresą.';

  @override
  String get exceptionAddressLookupFailed => 'Nepavyko prisijungti prie įrenginio. Patikrinkite interneto ryšį ar pateiktą įrenginio adresą.';

  @override
  String get exceptionConnectionRefused => 'Nepavyko prisijungti prie įrenginio. Patikrinkite pateiktą įrenginio adresą.';

  @override
  String get exceptionHttpConnectionTimeout => 'Laikas užklausai į įrenginio serverį baigėsi. Patikrinkite tinklo ryšį.';

  @override
  String get exceptionHttpSendTimeout => 'Laikas užklausai į įrenginio serverį baigėsi. Patikrinkite tinklo ryšį.';

  @override
  String get exceptionHttpReceiveTimeout => 'Laikas užklausai gauti iš įrenginio serverio baigėsi. Patikrinkite tinklo ryšį.';

  @override
  String get exceptionHttpBadCertificate => 'Užklausa nepavyko. Blogas sertifikatas buvo pateiktas serveriui. Ši klaida neturėjo nutikti. Apie tai praneškite programinės įrangos kurėjams.';

  @override
  String exceptionHttpBadResponse(String code) {
    return 'Netikėtas atsakas iš įrenginio serverio ($code). Užklausa nepavyko. Ši klaida neturėjo nutikti. Apie tai praneškite programinės įrangos kurėjams.';
  }

  @override
  String get exceptionHttpCancel => 'Užklausa buvo atšaukta. Ši klaida neturėjo nutikti. Apie tai praneškite programinės įrangos kurėjams.';

  @override
  String get exceptionHttpConnectionError => 'Nepavyko prisijungti prie įrenginio serverio. Patikrinkite tinklo ryšį.';

  @override
  String get exceptionHttpUnknown => 'Įvyko netikėta tinklo problema. Tai gali būti interneto ryšio arba įrenginio serverio sutrikimai.';

  @override
  String get mainscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get pMainGraphInfoTitle => 'Temperatūros ir galios grafikas';

  @override
  String pMainGraphInfoText(int seconds, num hours) {
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
  String get pMainGraphInfoLegend => 'Linijų legenda';

  @override
  String get devicesScreenIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

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
  String get settingsscreenIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get pSettingsTitle => 'Nustatymai';

  @override
  String get pSettingsSectionGeneralTitle => 'Bendri';

  @override
  String get pSettingsLanguage => 'Kalba';

  @override
  String get cLanguageSelectDialogTitle => 'Pasirinkite kalbą';

  @override
  String pSettingsInputLanguage(String locale) {
    String _temp0 = intl.Intl.selectLogic(
      locale,
      {
        'lt': 'Lietuvių',
        'en': 'Anglų',
        'lv': 'Latvių',
        'other': 'nežinoma',
      },
    );
    return '$_temp0';
  }

  @override
  String get pSettingsTheme => 'Tema';

  @override
  String get cThemeSelectDialogTitle => 'Pasirinkite temą';

  @override
  String pSettingsThemeNames(String theme) {
    String _temp0 = intl.Intl.selectLogic(
      theme,
      {
        'light': 'Šviesi',
        'lightMediumContrast': 'Šviesi - vidutinio kontrasto',
        'lightHighContrast': 'Šviesi - didelio kontrasto',
        'dark': 'Tamsi',
        'darkMediumContrast': 'Tamsi - vidutinio kontrasto',
        'darkHighContrast': 'Tamsi - didelio kontrasto',
        'other': 'nežinoma tema',
      },
    );
    return '$_temp0';
  }

  @override
  String get layoutIIIIIIIIIIIIIIIIIIIIIIIIIIII => '----------------------------------------------------';

  @override
  String get layoutItemHome => 'Pagrindinis';

  @override
  String get layoutItemDevices => 'Įrenginiai';

  @override
  String get layoutItemSettings => 'Nustatymai';
}
