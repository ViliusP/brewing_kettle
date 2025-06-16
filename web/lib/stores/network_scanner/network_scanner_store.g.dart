// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_scanner_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NetworkScannerStore on _NetworkScannerStore, Store {
  Computed<List<RecordMDNS>>? _$recordsComputed;

  @override
  List<RecordMDNS> get records =>
      (_$recordsComputed ??= Computed<List<RecordMDNS>>(
            () => super.records,
            name: '_NetworkScannerStore.records',
          ))
          .value;
  Computed<NetworkScannerState>? _$stateComputed;

  @override
  NetworkScannerState get state =>
      (_$stateComputed ??= Computed<NetworkScannerState>(
            () => super.state,
            name: '_NetworkScannerStore.state',
          ))
          .value;

  late final _$_recordsAtom = Atom(
    name: '_NetworkScannerStore._records',
    context: context,
  );

  @override
  List<RecordMDNS> get _records {
    _$_recordsAtom.reportRead();
    return super._records;
  }

  @override
  set _records(List<RecordMDNS> value) {
    _$_recordsAtom.reportWrite(value, super._records, () {
      super._records = value;
    });
  }

  late final _$_stateAtom = Atom(
    name: '_NetworkScannerStore._state',
    context: context,
  );

  @override
  NetworkScannerState get _state {
    _$_stateAtom.reportRead();
    return super._state;
  }

  @override
  set _state(NetworkScannerState value) {
    _$_stateAtom.reportWrite(value, super._state, () {
      super._state = value;
    });
  }

  late final _$startAsyncAction = AsyncAction(
    '_NetworkScannerStore.start',
    context: context,
  );

  @override
  Future<dynamic> start() {
    return _$startAsyncAction.run(() => super.start());
  }

  @override
  String toString() {
    return '''
records: ${records},
state: ${state}
    ''';
  }
}
