import 'package:brew_kettle_dashboard/core/data/models/api/pid_constants.dart';

/// Represents system information containing both communicator and heater device details.
class SystemInfo {
  /// Information about the communication device.
  final DeviceInfo communicator;

  /// Detailed information about the heater device.
  final HeaterDeviceInfo heater;

  /// Creates a [SystemInfo] instance with required device information.
  const SystemInfo({required this.communicator, required this.heater});

  /// Parses [SystemInfo] from JSON data according to the device communication protocol.
  ///
  /// Expected JSON structure:
  /// ```json
  /// {
  ///   "communicator": {...},
  ///   "heater": {...}
  /// }
  /// ```
  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    var communicatorJson = json["communicator"];
    DeviceInfo communicator = const DeviceInfo.empty();
    if (communicatorJson is Map<String, dynamic>) {
      communicator = DeviceInfo.fromJson(communicatorJson);
    }

    var heaterJson = json["heater"];
    HeaterDeviceInfo heater = const HeaterDeviceInfo.empty();
    if (heaterJson is Map<String, dynamic>) {
      heater = HeaterDeviceInfo.fromJson(heaterJson);
    }
    return SystemInfo(heater: heater, communicator: communicator);
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

/// Base class for device information containing hardware and software details.
class DeviceInfo {
  /// Hardware specifications of the device.
  final DeviceHardwareInfo hardware;

  /// Software/firmware information of the device.
  final DeviceSoftwareInfo software;

  /// Creates a [DeviceInfo] instance with required hardware/software details.
  const DeviceInfo({required this.hardware, required this.software});

  /// Empty/default device information instance.
  ///
  /// Useful for initialization or error states.
  const DeviceInfo.empty({
    this.hardware = const DeviceHardwareInfo(),
    this.software = const DeviceSoftwareInfo(),
  });

  /// Parses [DeviceInfo] from JSON data.
  ///
  /// Handles missing/malformed hardware/software data by falling back to defaults.
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

/// Specialized device information for heater devices.
///
/// Implements [DeviceInfo] with heater-specific software details.
class HeaterDeviceInfo implements DeviceInfo {
  @override
  final DeviceHardwareInfo hardware;

  /// Heater-specific software information including PID constants.
  @override
  final HeaterDeviceSoftwareInfo software;

  /// Creates a [HeaterDeviceInfo] instance with heater-specific details.
  const HeaterDeviceInfo({required this.software, required this.hardware});

  /// Empty/default heater device information instance.
  const HeaterDeviceInfo.empty()
    : hardware = const DeviceHardwareInfo(),
      software = const HeaterDeviceSoftwareInfo();

  /// Parses [HeaterDeviceInfo] from JSON data.
  ///
  /// Uses specialized parser for heater-specific software information.
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

/// Detailed hardware specifications for a device.
class DeviceHardwareInfo {
  /// Chip model/version information.
  final String? chip;

  /// Number of processing cores.
  final int? cores;

  /// Set of supported hardware features.
  final Set<ChipFeatures> features;

  /// Silicon revision identifier.
  final String? siliconRevision;

  /// Flash memory information (in bytes).
  final FlashInfo flash;

  /// Minimum heap size requirement (in bytes).
  final int? minimumHeapSize;

  /// Creates a [DeviceHardwareInfo] instance.
  const DeviceHardwareInfo({
    this.chip,
    this.cores,
    this.features = const {},
    this.flash = const FlashInfo(),
    this.siliconRevision,
    this.minimumHeapSize,
  });

  /// Parses [DeviceHardwareInfo] from JSON data
  ///
  /// Gracefully handles missing data and malformed feature entries
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

/// Base software/firmware information for a device.
class DeviceSoftwareInfo {
  /// Application version string.
  final String? version;

  /// Secure version
  final int? secureVersion;

  /// Underlying framework version (e.g., IDF version).
  final String? idfVersion;

  /// Name of the deployed project/application.
  final String? projectName;

  /// Combined compile date and time string.
  final String? compileTime;

  /// Creates a [DeviceSoftwareInfo] instance.
  const DeviceSoftwareInfo({
    this.projectName,
    this.version,
    this.secureVersion,
    this.idfVersion,
    this.compileTime,
  });

  /// Parses [DeviceSoftwareInfo] from JSON data.
  ///
  /// Combines separate date/time fields from the source JSON.
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

/// Flash memory configuration details.
class FlashInfo {
  /// Total size in bytes.
  final int? size;

  /// Type of flash memory.
  final FlashType? type;

  /// Creates a [FlashInfo] instance.
  const FlashInfo({this.size, this.type});

  /// Parses [FlashInfo] from JSON data.
  ///
  /// Handles unknown flash types by returning null.
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

/// Heater-specific software information extending base device software.
class HeaterDeviceSoftwareInfo extends DeviceSoftwareInfo {
  /// Creates [HeaterDeviceSoftwareInfo] with optional PID constants.
  const HeaterDeviceSoftwareInfo({
    super.projectName,
    super.version,
    super.secureVersion,
    super.idfVersion,
    super.compileTime,
  });

  /// Parses [HeaterDeviceSoftwareInfo] from JSON data.
  ///
  /// Includes parsing of PID constants if present.
  factory HeaterDeviceSoftwareInfo.fromJson(Map<String, dynamic> json) {
    final String? projectName = json["project_name"];
    final String? version = json["version"];
    final int? secureVersion = json["secure_version"];
    final String? idfVersion = json["idf_version"];
    final String? compileTime = json["compile_time"];
    final String? compileDate = json["compile_date"];

    return HeaterDeviceSoftwareInfo(
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
      other is HeaterDeviceSoftwareInfo &&
          runtimeType == other.runtimeType &&
          version == other.version &&
          secureVersion == other.secureVersion &&
          idfVersion == other.idfVersion &&
          projectName == other.projectName &&
          compileTime == other.compileTime;

  @override
  int get hashCode => Object.hash(version, secureVersion, idfVersion, projectName, compileTime);
}

/// Enumeration of supported chip features.
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

/// Enumeration of flash memory types.
enum FlashType {
  /// Built-in/internal flash memory
  embedded,

  /// External flash chip
  external,
}
