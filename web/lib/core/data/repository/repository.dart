import 'package:brew_kettle_dashboard/core/data/storages/sharedpref/shared_preference_helper.dart';

class Repository {
  // Sub repos

  final SharedPreferenceHelper _sharedPrefsHelper;

  Repository(
    this._sharedPrefsHelper,
  );

  SharedPreferenceHelper get sharedPreferences {
    return _sharedPrefsHelper;
  }
}
