// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LocaleStore on _LocaleStore, Store {
  Computed<Locale>? _$localeComputed;

  @override
  Locale get locale =>
      (_$localeComputed ??= Computed<Locale>(() => super.locale, name: '_LocaleStore.locale'))
          .value;

  late final _$_localeAtom = Atom(name: '_LocaleStore._locale', context: context);

  @override
  Locale get _locale {
    _$_localeAtom.reportRead();
    return super._locale;
  }

  @override
  set _locale(Locale value) {
    _$_localeAtom.reportWrite(value, super._locale, () {
      super._locale = value;
    });
  }

  late final _$_LocaleStoreActionController = ActionController(
    name: '_LocaleStore',
    context: context,
  );

  @override
  void changeLanguage(Locale locale) {
    final _$actionInfo = _$_LocaleStoreActionController.startAction(
      name: '_LocaleStore.changeLanguage',
    );
    try {
      return super.changeLanguage(locale);
    } finally {
      _$_LocaleStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
locale: ${locale}
    ''';
  }
}
