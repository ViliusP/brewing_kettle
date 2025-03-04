import 'package:brew_kettle_dashboard/core/data/models/app_exception/app_exception.dart';
import 'package:mobx/mobx.dart';

part 'exception_store.g.dart';

// ignore: library_private_types_in_public_api
class ExceptionStore = _ExceptionStore with _$ExceptionStore;

abstract class _ExceptionStore with Store {
  _ExceptionStore();

  // ===================
  // store variables:
  // ===================
  @observable
  ObservableList<AppException> _exceptions = ObservableList.of([]);

  @computed
  int get count => _exceptions.length;

  // =============
  // actions:
  // =============

  /// Returns first error and removes it from the list.
  @action
  AppException? pop() {
    if (_exceptions.isEmpty) return null;
    dynamic error = _exceptions.first;
    _exceptions.removeAt(0);
    return error;
  }

  @action
  void push(Exception exception) {
    _exceptions.add(AppException.of(exception));
  }
}
