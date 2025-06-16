// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_debugging_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppDebuggingStore on _AppDebuggingStore, Store {
  Computed<Offset?>? _$pointerPositionComputed;

  @override
  Offset? get pointerPosition =>
      (_$pointerPositionComputed ??= Computed<Offset?>(
            () => super.pointerPosition,
            name: '_AppDebuggingStore.pointerPosition',
          ))
          .value;

  late final _$_pointerPositionAtom = Atom(
    name: '_AppDebuggingStore._pointerPosition',
    context: context,
  );

  @override
  Offset? get _pointerPosition {
    _$_pointerPositionAtom.reportRead();
    return super._pointerPosition;
  }

  @override
  set _pointerPosition(Offset? value) {
    _$_pointerPositionAtom.reportWrite(value, super._pointerPosition, () {
      super._pointerPosition = value;
    });
  }

  late final _$_AppDebuggingStoreActionController = ActionController(
    name: '_AppDebuggingStore',
    context: context,
  );

  @override
  void setPointerPosition(Offset value) {
    final _$actionInfo = _$_AppDebuggingStoreActionController.startAction(
      name: '_AppDebuggingStore.setPointerPosition',
    );
    try {
      return super.setPointerPosition(value);
    } finally {
      _$_AppDebuggingStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
pointerPosition: ${pointerPosition}
    ''';
  }
}
