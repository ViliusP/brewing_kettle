import 'dart:developer';

import 'package:brew_kettle_dashboard/core/data/models/api/device_configuration.dart';
import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:brew_kettle_dashboard/stores/exception/exception_store.dart';
import 'package:mobx/mobx.dart';

part 'system_info_store.g.dart';

// ignore: library_private_types_in_public_api
class SystemInfoStore = _SystemInfoStore with _$SystemInfoStore;

abstract class _SystemInfoStore with Store {
  final ExceptionStore _errorStore;
  final Repository _repository;

  _SystemInfoStore({required Repository repository, required ExceptionStore errorStore})
    : _errorStore = errorStore,
      _repository = repository;

  @observable
  SystemInfo? info;

  @computed
  bool get loading => _loading;

  @observable
  bool _loading = false;

  @action
  Future request() async {
    try {
      _loading = true;
      info = await _repository.systemInfo.get();
    } on Exception catch (exception) {
      _errorStore.push(exception);
      log('Exception occured when requesting system info: $exception');
    } catch (err) {
      log('Error occured when requesting system info: $err');
      rethrow;
    } finally {
      _loading = false;
    }
  }

  void dispose() async {}
}
