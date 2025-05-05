part of 'inbound_message.dart';

class DeviceSnapshot extends WsInboundMessagePayload {
  /// Buffer in RGB888 format encoded in Base64.
  ///
  /// To use it:
  ///
  /// ```dart
  /// //...
  /// // Snapshot initialization.
  /// var snapshot = ...;
  /// //...
  /// var width = snapshot.width!;
  /// var height = snapshot.height!;
  /// var decoded = base64Decode(snapshot.buffer!);
  /// var bufferRGBA8888 = decoded.rgb888ToRgba8888(width, height);
  /// // Now it is compatible with Flutter, so can create Image.
  /// ```
  final String? buffer;
  final int? width;
  final int? height;

  DeviceSnapshot({this.buffer, this.height, this.width});

  factory DeviceSnapshot.fromJson(Map<String, dynamic> json) {
    final int? width = json["width"];
    final int? height = json["height"];
    final String? data = json["data"];

    return DeviceSnapshot(buffer: data, height: height, width: width);
  }
}
