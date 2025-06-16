// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ThemeStore on _ThemeStore, Store {
  Computed<AppThemeMode>? _$themeModeComputed;

  @override
  AppThemeMode get themeMode =>
      (_$themeModeComputed ??= Computed<AppThemeMode>(
            () => super.themeMode,
            name: '_ThemeStore.themeMode',
          ))
          .value;
  Computed<AppTheme>? _$themeComputed;

  @override
  AppTheme get theme =>
      (_$themeComputed ??= Computed<AppTheme>(
            () => super.theme,
            name: '_ThemeStore.theme',
          ))
          .value;

  late final _$_themeModeAtom = Atom(
    name: '_ThemeStore._themeMode',
    context: context,
  );

  @override
  AppThemeMode get _themeMode {
    _$_themeModeAtom.reportRead();
    return super._themeMode;
  }

  @override
  set _themeMode(AppThemeMode value) {
    _$_themeModeAtom.reportWrite(value, super._themeMode, () {
      super._themeMode = value;
    });
  }

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
  void changeThemeMode(AppThemeMode mode) {
    final _$actionInfo = _$_ThemeStoreActionController.startAction(
      name: '_ThemeStore.changeThemeMode',
    );
    try {
      return super.changeThemeMode(mode);
    } finally {
      _$_ThemeStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
themeMode: ${themeMode},
theme: ${theme}
    ''';
  }
}
