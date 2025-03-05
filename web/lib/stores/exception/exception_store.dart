import 'dart:async';

import 'package:brew_kettle_dashboard/core/data/models/app_exceptions/app_exception.dart';
import 'package:mobx/mobx.dart';

part 'exception_store.g.dart';

// ignore: library_private_types_in_public_api
class ExceptionStore = _ExceptionStore with _$ExceptionStore;

abstract class _ExceptionStore with Store {
  _ExceptionStore();

  // ===================
  // store variables:
  // ===================
  final StreamController<AppException> _streamController = StreamController<AppException>();

  late ObservableStream<AppException> stream = ObservableStream(_streamController.stream);

  // =============
  // actions:
  // =============
  @action
  void push(Exception exception) {
    if (_streamController.isPaused || _streamController.isClosed) {
      return;
    }
    _streamController.add(AppException.of(exception));
  }
}
