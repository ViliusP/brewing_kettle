// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_info_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SystemInfoStore on _SystemInfoStore, Store {
  Computed<bool>? _$loadingComputed;

  @override
  bool get loading =>
      (_$loadingComputed ??= Computed<bool>(
            () => super.loading,
            name: '_SystemInfoStore.loading',
          ))
          .value;

  late final _$infoAtom = Atom(name: '_SystemInfoStore.info', context: context);

  @override
  SystemInfo? get info {
    _$infoAtom.reportRead();
    return super.info;
  }

  @override
  set info(SystemInfo? value) {
    _$infoAtom.reportWrite(value, super.info, () {
      super.info = value;
    });
  }

  late final _$_loadingAtom = Atom(
    name: '_SystemInfoStore._loading',
    context: context,
  );

  @override
  bool get _loading {
    _$_loadingAtom.reportRead();
    return super._loading;
  }

  @override
  set _loading(bool value) {
    _$_loadingAtom.reportWrite(value, super._loading, () {
      super._loading = value;
    });
  }

  late final _$requestAsyncAction = AsyncAction(
    '_SystemInfoStore.request',
    context: context,
  );

  @override
  Future<dynamic> request() {
    return _$requestAsyncAction.run(() => super.request());
  }

  @override
  String toString() {
    return '''
info: ${info},
loading: ${loading}
    ''';
  }
}
