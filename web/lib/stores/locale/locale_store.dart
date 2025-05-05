import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:flutter/rendering.dart';
import 'package:mobx/mobx.dart';

part 'locale_store.g.dart';

// ignore: library_private_types_in_public_api
class LocaleStore = _LocaleStore with _$LocaleStore;

abstract class _LocaleStore with Store {
  final Repository _repository;

  _LocaleStore(Repository repository) : _repository = repository {
    _init();
  }

  // ===================
  // Store variables:
  // ===================
  @observable
  Locale _locale = AppLocalizations.supportedLocales.first;

  @computed
  Locale get locale => _locale;

  // ==============
  // Actions:
  // ==============
  @action
  void changeLocale(Locale value) {
    _locale = value;
    _repository.sharedPreferences.setLocale(locale.languageCode);
  }

  // ======================
  // General:
  // ======================
  void _init() {
    String? prefLocale = _repository.sharedPreferences.locale;

    _locale = switch (prefLocale) {
      "en" => Locale("en"),
      "lt" => Locale("lt"),
      _ => AppLocalizations.supportedLocales.first,
    };
  }

  void dispose() async {}
}
