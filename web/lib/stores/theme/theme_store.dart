import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:mobx/mobx.dart';

part 'theme_store.g.dart';

// ignore: library_private_types_in_public_api
class ThemeStore = _ThemeStore with _$ThemeStore;

abstract class _ThemeStore with Store {
  final Repository _repository;

  _ThemeStore(Repository repository) : _repository = repository {
    _init();
  }

  // ===================
  // Store variables:
  // ===================
  @computed
  AppTheme get theme => _theme;

  @observable
  AppTheme _theme = AppDefaults.theme;

  // ==============
  // Actions:
  // ==============
  @action
  void changeTheme(AppTheme value) {
    _theme = value;
    _repository.sharedPreferences.setTheme(value.key);
  }

  // ======================
  // General:
  // ======================
  void _init() async {
    String? prefTheme = _repository.sharedPreferences.theme;
    _theme = AppTheme.values.firstWhere((v) => v.name == prefTheme, orElse: () => AppTheme.light);
  }

  void dispose() async {}
}
