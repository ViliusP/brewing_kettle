import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';

part 'app_debugging_store.g.dart';

// ignore: library_private_types_in_public_api
class AppDebuggingStore = _AppDebuggingStore with _$AppDebuggingStore;

abstract class _AppDebuggingStore with Store {
  // ignore: unused_field
  final Repository _repository;

  _AppDebuggingStore(Repository repository) : _repository = repository {
    _init();
  }

  // ===================
  // Store variables:
  // ===================
  @observable
  Offset? _pointerPosition;

  @computed
  Offset? get pointerPosition => _pointerPosition;

  // ==============
  // Actions:
  // ==============
  @action
  void setPointerPosition(Offset value) {
    _pointerPosition = value;
  }

  // ======================
  // General:
  // ======================
  void _init() async {}

  void dispose() async {}
}
