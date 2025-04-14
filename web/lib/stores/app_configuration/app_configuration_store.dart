import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:mobx/mobx.dart';

part 'app_configuration_store.g.dart';

// ignore: library_private_types_in_public_api
class AppConfigurationStore = _AppConfigurationStore with _$AppConfigurationStore;

abstract class _AppConfigurationStore with Store {
  final Repository _repository;

  _AppConfigurationStore(Repository repository) : _repository = repository {
    _init();
  }

  // ===================
  // Store variables:
  // ===================
  @observable
  bool _isAdvancedMode = AppDefaults.isAdvancedMode;

  @computed
  bool get isAdvancedMode => _isAdvancedMode;

  // ==============
  // Actions:
  // ==============
  @action
  void setAdvancedMode(bool value) {
    _isAdvancedMode = value;
    _repository.sharedPreferences.setAdvancedMode(value);
  }

  // ======================
  // General:
  // ======================
  void _init() async {
    bool? prefsAdvancedMode = _repository.sharedPreferences.advancedMode;
    if (prefsAdvancedMode != null) {
      _isAdvancedMode = prefsAdvancedMode;
    }
  }

  void dispose() async {}
}
