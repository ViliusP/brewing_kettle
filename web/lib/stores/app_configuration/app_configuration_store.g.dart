// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_configuration_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppConfigurationStore on _AppConfigurationStore, Store {
  Computed<bool>? _$isAdvancedModeComputed;

  @override
  bool get isAdvancedMode =>
      (_$isAdvancedModeComputed ??= Computed<bool>(() => super.isAdvancedMode,
              name: '_AppConfigurationStore.isAdvancedMode'))
          .value;

  late final _$_isAdvancedModeAtom =
      Atom(name: '_AppConfigurationStore._isAdvancedMode', context: context);

  @override
  bool get _isAdvancedMode {
    _$_isAdvancedModeAtom.reportRead();
    return super._isAdvancedMode;
  }

  @override
  set _isAdvancedMode(bool value) {
    _$_isAdvancedModeAtom.reportWrite(value, super._isAdvancedMode, () {
      super._isAdvancedMode = value;
    });
  }

  late final _$_AppConfigurationStoreActionController =
      ActionController(name: '_AppConfigurationStore', context: context);

  @override
  void setAdvancedMode(bool value) {
    final _$actionInfo = _$_AppConfigurationStoreActionController.startAction(
        name: '_AppConfigurationStore.setAdvancedMode');
    try {
      return super.setAdvancedMode(value);
    } finally {
      _$_AppConfigurationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isAdvancedMode: ${isAdvancedMode}
    ''';
  }
}
