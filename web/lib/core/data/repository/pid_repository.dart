import 'package:brew_kettle_dashboard/core/data/models/api/pid_constants.dart';
import 'package:brew_kettle_dashboard/core/data/network/kettle_api/pid_api.dart';

class PidRepository {
  final PidApi _pidApi;

  PidRepository(PidApi pidApi) : _pidApi = pidApi;

  Future<PidConstants> changeConstants({
    double? proportional,
    double? integral,
    double? derivative,
  }) async {
    return _pidApi.patchConstants(
      proportional: proportional,
      integral: integral,
      derivative: derivative,
    );
  }
}
