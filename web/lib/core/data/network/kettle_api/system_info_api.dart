import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/network/kettle_client.dart';
import 'package:brew_kettle_dashboard/core/data/network/kettle_api/endpoints.dart';

class SystemInfoApi {
  final KettleClient _client;

  const SystemInfoApi({required KettleClient client}) : _client = client;

  Future<SystemInfo> getInfo() async {
    final response = await _client.get(KettleApiEndpoint.systemInfo.path);
    try {
      return SystemInfo.fromJson(response.data);
    } on Exception catch (e) {
      throw Exception('Failed to parse system info: $e');
    }
  }
}
