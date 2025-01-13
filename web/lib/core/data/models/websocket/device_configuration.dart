part of 'inbound_message.dart';

class DeviceConfiguration extends WsInboundMessagePayload {
  final String? chip;
  final int? cores;
  final Set<ChipFeatures> features;
  final String? siliconRevision;

  // In bytes
  final int? flashSize;
  final FlashType? flashType;

  // In bytes
  final int? minimumHeapSize;

  DeviceConfiguration({
    required this.chip,
    required this.cores,
    required this.features,
    required this.siliconRevision,
    required this.flashSize,
    required this.flashType,
    required this.minimumHeapSize,
  });

  factory DeviceConfiguration.fromJson(Map<String, dynamic> json) {
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

    final int? flashSize = json["flash_size"];

    FlashType? flashType;
    try {
      flashType = FlashType.values.byName(json["flash_type"].toString());
      // ignore: empty_catches
    } catch (e) {}

    final int? minimumHeapSize = json["heap_size"];

    return DeviceConfiguration(
      chip: chip,
      cores: cores,
      features: features,
      siliconRevision: siliconRevision,
      flashSize: flashSize,
      flashType: flashType,
      minimumHeapSize: minimumHeapSize,
    );
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
