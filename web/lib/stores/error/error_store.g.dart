// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ErrorStore on _ErrorStore, Store {
  late final _$_errorAtom = Atom(name: '_ErrorStore._error', context: context);

  @override
  dynamic get _error {
    _$_errorAtom.reportRead();
    return super._error;
  }

  @override
  set _error(dynamic value) {
    _$_errorAtom.reportWrite(value, super._error, () {
      super._error = value;
    });
  }

  late final _$_ErrorStoreActionController = ActionController(
    name: '_ErrorStore',
    context: context,
  );

  @override
  void setError(dynamic error) {
    final _$actionInfo = _$_ErrorStoreActionController.startAction(name: '_ErrorStore.setError');
    try {
      return super.setError(error);
    } finally {
      _$_ErrorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic error() {
    final _$actionInfo = _$_ErrorStoreActionController.startAction(name: '_ErrorStore.error');
    try {
      return super.error();
    } finally {
      _$_ErrorStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''

    ''';
  }
}
