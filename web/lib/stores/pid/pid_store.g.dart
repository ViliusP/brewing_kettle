// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pid_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PidStore on _PidStore, Store {
  Computed<double?>? _$proportionalComputed;

  @override
  double? get proportional =>
      (_$proportionalComputed ??= Computed<double?>(() => super.proportional,
              name: '_PidStore.proportional'))
          .value;
  Computed<double?>? _$integralComputed;

  @override
  double? get integral => (_$integralComputed ??=
          Computed<double?>(() => super.integral, name: '_PidStore.integral'))
      .value;
  Computed<double?>? _$derivativeComputed;

  @override
  double? get derivative =>
      (_$derivativeComputed ??= Computed<double?>(() => super.derivative,
              name: '_PidStore.derivative'))
          .value;
  Computed<bool>? _$isConstantsChangingComputed;

  @override
  bool get isConstantsChanging => (_$isConstantsChangingComputed ??=
          Computed<bool>(() => super.isConstantsChanging,
              name: '_PidStore.isConstantsChanging'))
      .value;

  late final _$_pidConstantsAtom =
      Atom(name: '_PidStore._pidConstants', context: context);

  @override
  PidConstants? get _pidConstants {
    _$_pidConstantsAtom.reportRead();
    return super._pidConstants;
  }

  @override
  set _pidConstants(PidConstants? value) {
    _$_pidConstantsAtom.reportWrite(value, super._pidConstants, () {
      super._pidConstants = value;
    });
  }

  late final _$_isConstantsChangingAtom =
      Atom(name: '_PidStore._isConstantsChanging', context: context);

  @override
  bool get _isConstantsChanging {
    _$_isConstantsChangingAtom.reportRead();
    return super._isConstantsChanging;
  }

  @override
  set _isConstantsChanging(bool value) {
    _$_isConstantsChangingAtom.reportWrite(value, super._isConstantsChanging,
        () {
      super._isConstantsChanging = value;
    });
  }

  late final _$changeConstantsAsyncAction =
      AsyncAction('_PidStore.changeConstants', context: context);

  @override
  Future<dynamic> changeConstants(
      {required double proportional,
      required double integral,
      required double derivative}) {
    return _$changeConstantsAsyncAction.run(() => super.changeConstants(
        proportional: proportional,
        integral: integral,
        derivative: derivative));
  }

  late final _$_PidStoreActionController =
      ActionController(name: '_PidStore', context: context);

  @override
  void _onData(WsInboundMessage<WsInboundMessagePayload> message) {
    final _$actionInfo =
        _$_PidStoreActionController.startAction(name: '_PidStore._onData');
    try {
      return super._onData(message);
    } finally {
      _$_PidStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
proportional: ${proportional},
integral: ${integral},
derivative: ${derivative},
isConstantsChanging: ${isConstantsChanging}
    ''';
  }
}
