part of 'inbound_message.dart';

class DeviceSnapshot extends WsInboundMessagePayload {
  final int? height;
  final int? width;

  DeviceSnapshot({this.height, this.width});

  factory DeviceSnapshot.fromJson(Map<String, dynamic> json) {
    // final String? chip = json["chip"];
    // final int? cores = json["cores"];

    // final Set<ChipFeatures> features = {};
    // try {
    //   final rawFeatures = json["features"] as List;
    //   for (var rawFeature in rawFeatures) {
    //     features.add(ChipFeatures.values.byName(rawFeature.toString()));
    //   }
    //   // ignore: empty_catches
    // } catch (e) {}

    // final String? siliconRevision = json["silicon_revision"];
    // final int? flashSize = json["flash_size"];
    // final int? minimumHeapSize = json["heap_size"];

    return DeviceSnapshot();
  }
}
