// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ThemeStore on _ThemeStore, Store {
  Computed<AppTheme>? _$themeComputed;

  @override
  AppTheme get theme =>
      (_$themeComputed ??= Computed<AppTheme>(() => super.theme, name: '_ThemeStore.theme')).value;

  late final _$_themeAtom = Atom(name: '_ThemeStore._theme', context: context);

  @override
  AppTheme get _theme {
    _$_themeAtom.reportRead();
    return super._theme;
  }

  @override
  set _theme(AppTheme value) {
    _$_themeAtom.reportWrite(value, super._theme, () {
      super._theme = value;
    });
  }

  late final _$_ThemeStoreActionController = ActionController(
    name: '_ThemeStore',
    context: context,
  );

  @override
  void changeTheme(AppTheme value) {
    final _$actionInfo = _$_ThemeStoreActionController.startAction(name: '_ThemeStore.changeTheme');
    try {
      return super.changeTheme(value);
    } finally {
      _$_ThemeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
theme: ${theme}
    ''';
  }
}
