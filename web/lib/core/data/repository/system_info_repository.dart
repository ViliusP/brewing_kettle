import 'package:brew_kettle_dashboard/core/data/models/api/device_configuration.dart';
import 'package:brew_kettle_dashboard/core/data/network/kettle_api/system_info_api.dart';

class SystemInfoRepository {
  final SystemInfoApi _api;

  const SystemInfoRepository(SystemInfoApi api) : _api = api;

  Future<SystemInfo> get() => _api.getInfo();
}
