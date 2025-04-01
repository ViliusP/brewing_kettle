import 'package:brew_kettle_dashboard/core/data/models/api/pid_constants.dart';
import 'package:brew_kettle_dashboard/core/data/network/kettle_client.dart';
import 'package:brew_kettle_dashboard/core/data/network/kettle_api/endpoints.dart';

class PidApi {
  final KettleClient _client;

  const PidApi({required KettleClient client}) : _client = client;

  Future<PidConstants> getConstants() async {
    final response = await _client.get(KettleApiEndpoint.pid.path);
    try {
      return PidConstants.fromJson(response.data);
    } on Exception catch (e) {
      throw Exception('Failed to parse system info: $e');
    }
  }

  Future<PidConstants> patchConstants({
    double? proportional,
    double? integral,
    double? derivative,
  }) async {
    Map<String, dynamic> data = {};
    if (proportional != null) data['proportional'] = proportional;
    if (integral != null) data['integral'] = integral;
    if (derivative != null) data['derivative'] = derivative;

    final response = await _client.patch(KettleApiEndpoint.pid.path, data: data);
    try {
      return PidConstants.fromJson(response.data);
    } on Exception catch (e) {
      throw Exception('Failed to parse system info: $e');
    }
  }
}
