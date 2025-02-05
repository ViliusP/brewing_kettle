import 'package:mobx/mobx.dart';

part 'error_store.g.dart';

// ignore: library_private_types_in_public_api
class ErrorStore = _ErrorStore with _$ErrorStore;

abstract class _ErrorStore with Store {
  _ErrorStore();

  // ===================
  // store variables:
  // ===================
  @observable
  dynamic _error;

  // =============
  // actions:
  // =============
  @action
  void setError(dynamic error) {
    _error = error;
  }

  @action
  dynamic error() {
    dynamic err = _error;
    _error = null;
    return err;
  }
}
