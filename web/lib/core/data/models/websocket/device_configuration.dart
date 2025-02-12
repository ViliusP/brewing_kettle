part of 'inbound_message.dart';

class SystemControllers extends WsInboundMessagePayload {
  final DeviceInfo communicator;
  final DeviceInfo heater;

  const SystemControllers({
    required this.communicator,
    required this.heater,
  });

  factory SystemControllers.fromJson(Map<String, dynamic> json) {
    return SystemControllers(
      heater: DeviceInfo.empty(),
      communicator: DeviceInfo.fromJson(json),
    );
  }
}

class DeviceInfo {
  final DeviceHardwareInfo hardware;
  final DeviceSoftwareInfo software;

  const DeviceInfo({
    required this.hardware,
    required this.software,
  });

  const DeviceInfo.empty({
    this.hardware = const DeviceHardwareInfo(),
    this.software = const DeviceSoftwareInfo(),
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    var hardwareJson = json["hardware"];
    var hardwareInfo = const DeviceHardwareInfo();
    if (hardwareJson is Map<String, dynamic>) {
      hardwareInfo = DeviceHardwareInfo.fromJson(hardwareJson);
    }

    var softwareJson = json["software"];
    var softwareInfo = DeviceSoftwareInfo();
    if (softwareJson is Map<String, dynamic>) {
      softwareInfo = DeviceSoftwareInfo.fromJson(softwareJson);
    }

    return DeviceInfo(hardware: hardwareInfo, software: softwareInfo);
  }
}

class DeviceHardwareInfo {
  final String? chip;
  final int? cores;
  final Set<ChipFeatures> features;
  final String? siliconRevision;

  // In bytes
  final FlashInfo flash;

  // In bytes
  final int? minimumHeapSize;

  const DeviceHardwareInfo({
    this.chip,
    this.cores,
    this.features = const {},
    this.flash = const FlashInfo(),
    this.siliconRevision,
    this.minimumHeapSize,
  });

  factory DeviceHardwareInfo.fromJson(Map<String, dynamic> json) {
    final String? chip = json["chip"];
    final int? cores = json["cores"];
    final String? siliconRevision = json["silicon_revision"];

    final Set<ChipFeatures> features = {};
    try {
      final rawFeatures = json["features"] as List;
      for (var rawFeature in rawFeatures) {
        features.add(ChipFeatures.values.byName(rawFeature.toString()));
      }
      // ignore: empty_catches
    } catch (e) {}

    var flashJson = json["flash"];
    var flashInfo = FlashInfo();
    if (flashJson is Map<String, dynamic>) {
      flashInfo = FlashInfo.fromJson(flashJson);
    }

    final int? minimumHeapSize = json["heap_size"];

    return DeviceHardwareInfo(
      chip: chip,
      cores: cores,
      features: features,
      siliconRevision: siliconRevision,
      flash: flashInfo,
      minimumHeapSize: minimumHeapSize,
    );
  }
}

class DeviceSoftwareInfo {
  /// Application version
  final String? version;

  /// Secure version
  final int? secureVersion;

  /// IDF version
  final String? idfVersion;

  /// Project name
  final String? projectName;

  /// Compile date + time
  final String? compileTime;

  const DeviceSoftwareInfo({
    this.projectName,
    this.version,
    this.secureVersion,
    this.idfVersion,
    this.compileTime,
  });

  factory DeviceSoftwareInfo.fromJson(Map<String, dynamic> json) {
    final String? projectName = json["project_name"];
    final String? version = json["version"];
    final int? secureVersion = json["secure_version"];
    final String? idfVersion = json["idf_version"];
    final String? compileTime = json["compile_time"];
    final String? compileDate = json["compile_date"];

    return DeviceSoftwareInfo(
      projectName: projectName,
      version: version,
      secureVersion: secureVersion,
      idfVersion: idfVersion,
      compileTime: "$compileDate $compileTime",
    );
  }
}

class FlashInfo {
  final int? size;
  final FlashType? type;

  const FlashInfo({this.size, this.type});

  factory FlashInfo.fromJson(Map<String, dynamic> json) {
    final int? size = json["size"];

    FlashType? type;
    try {
      type = FlashType.values.byName(json["type"].toString());
      // ignore: empty_catches
    } catch (e) {}

    return FlashInfo(size: size, type: type);
  }
}

enum ChipFeatures {
  /// Wifi
  wifi,

  /// classic bluetooth
  bt,

  /// Bluetooth LE
  ble,

  /// 802.15.4 (Zigbee/Thread),
  ieee802154,
}

enum FlashType {
  embedded,
  external,
}
