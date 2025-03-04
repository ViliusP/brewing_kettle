// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exception_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ExceptionStore on _ExceptionStore, Store {
  Computed<int>? _$countComputed;

  @override
  int get count => (_$countComputed ??=
          Computed<int>(() => super.count, name: '_ExceptionStore.count'))
      .value;

  late final _$_exceptionsAtom =
      Atom(name: '_ExceptionStore._exceptions', context: context);

  @override
  ObservableList<AppException> get _exceptions {
    _$_exceptionsAtom.reportRead();
    return super._exceptions;
  }

  @override
  set _exceptions(ObservableList<AppException> value) {
    _$_exceptionsAtom.reportWrite(value, super._exceptions, () {
      super._exceptions = value;
    });
  }

  late final _$_ExceptionStoreActionController =
      ActionController(name: '_ExceptionStore', context: context);

  @override
  AppException? pop() {
    final _$actionInfo = _$_ExceptionStoreActionController.startAction(
        name: '_ExceptionStore.pop');
    try {
      return super.pop();
    } finally {
      _$_ExceptionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void push(Exception exception) {
    final _$actionInfo = _$_ExceptionStoreActionController.startAction(
        name: '_ExceptionStore.push');
    try {
      return super.push(exception);
    } finally {
      _$_ExceptionStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
count: ${count}
    ''';
  }
}
