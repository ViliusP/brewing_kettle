part of 'inbound_message.dart';

class SystemInfo extends WsInboundMessagePayload {
  final DeviceInfo communicator;
  final HeaterDeviceInfo heater;

  const SystemInfo({required this.communicator, required this.heater});

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    var heaterJson = json["heater"];
    var communicatorJson = json["communicator"];

    return SystemInfo(
      heater: HeaterDeviceInfo.fromJson(heaterJson),
      communicator: DeviceInfo.fromJson(communicatorJson),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemInfo &&
          runtimeType == other.runtimeType &&
          communicator == other.communicator &&
          heater == other.heater;

  @override
  int get hashCode => Object.hash(communicator, heater);
}

class DeviceInfo {
  final DeviceHardwareInfo hardware;
  final DeviceSoftwareInfo software;

  const DeviceInfo({required this.hardware, required this.software});

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo &&
          runtimeType == other.runtimeType &&
          hardware == other.hardware &&
          software == other.software;

  @override
  int get hashCode => Object.hash(hardware, software);
}

class HeaterDeviceInfo implements DeviceInfo {
  @override
  final DeviceHardwareInfo hardware;

  @override
  final HeaterDeviceSoftwareInfo software;

  const HeaterDeviceInfo({required this.software, required this.hardware});

  factory HeaterDeviceInfo.fromJson(Map<String, dynamic> json) {
    var hardwareJson = json["hardware"];
    var hardwareInfo = const DeviceHardwareInfo();
    if (hardwareJson is Map<String, dynamic>) {
      hardwareInfo = DeviceHardwareInfo.fromJson(hardwareJson);
    }

    var softwareJson = json["software"];
    var softwareInfo = HeaterDeviceSoftwareInfo();
    if (softwareJson is Map<String, dynamic>) {
      softwareInfo = HeaterDeviceSoftwareInfo.fromJson(softwareJson);
    }

    return HeaterDeviceInfo(hardware: hardwareInfo, software: softwareInfo);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaterDeviceInfo &&
          runtimeType == other.runtimeType &&
          hardware == other.hardware &&
          software == other.software;

  @override
  int get hashCode => Object.hash(hardware, software);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceHardwareInfo &&
          runtimeType == other.runtimeType &&
          chip == other.chip &&
          cores == other.cores &&
          features == other.features &&
          siliconRevision == other.siliconRevision &&
          flash == other.flash &&
          minimumHeapSize == other.minimumHeapSize;

  @override
  int get hashCode => Object.hash(chip, cores, features, siliconRevision, flash, minimumHeapSize);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceSoftwareInfo &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          secureVersion == other.secureVersion &&
          idfVersion == other.idfVersion &&
          projectName == other.projectName &&
          compileTime == other.compileTime;

  @override
  int get hashCode => Object.hash(version, secureVersion, idfVersion, projectName, compileTime);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashInfo &&
          runtimeType == other.runtimeType &&
          size == other.size &&
          type == other.type;

  @override
  int get hashCode => Object.hash(size, type);
}

class HeaterDeviceSoftwareInfo extends DeviceSoftwareInfo {
  final PidConstants? pidConstants;

  const HeaterDeviceSoftwareInfo({
    this.pidConstants,
    super.projectName,
    super.version,
    super.secureVersion,
    super.idfVersion,
    super.compileTime,
  });

  factory HeaterDeviceSoftwareInfo.fromJson(Map<String, dynamic> json) {
    final String? projectName = json["project_name"];
    final String? version = json["version"];
    final int? secureVersion = json["secure_version"];
    final String? idfVersion = json["idf_version"];
    final String? compileTime = json["compile_time"];
    final String? compileDate = json["compile_date"];

    PidConstants? pidConstants;
    if (json["pid_constants"] is Map<String, dynamic>) {
      pidConstants = PidConstants.fromJson(json["pid_constants"] as Map<String, dynamic>);
    }

    return HeaterDeviceSoftwareInfo(
      projectName: projectName,
      version: version,
      secureVersion: secureVersion,
      idfVersion: idfVersion,
      compileTime: "$compileDate $compileTime",
      pidConstants: pidConstants,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaterDeviceSoftwareInfo &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          secureVersion == other.secureVersion &&
          idfVersion == other.idfVersion &&
          projectName == other.projectName &&
          compileTime == other.compileTime &&
          pidConstants == other.pidConstants;

  @override
  int get hashCode =>
      Object.hash(version, secureVersion, idfVersion, projectName, compileTime, pidConstants);
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

enum FlashType { embedded, external }
