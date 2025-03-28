part of 'inbound_message.dart';

class MessageSimpleValue<T> implements WsInboundMessagePayload {
  final T value;

  final int timestamp;

  MessageSimpleValue(this.value, this.timestamp);

  factory MessageSimpleValue.fromJson(Map<String, dynamic> json) {
    dynamic value = json["value"];
    final int? timestamp = json["timestamp"];
    if (value == null || timestamp == null) {
      throw Exception("Cannot create MessageSimpleValue from $json");
    }
    if (T == double && value is int) {
      value = value.toDouble();
    }
    return MessageSimpleValue(value as T, timestamp);
  }

  @override
  String toString() {
    return 'MessageSimpleValue{value: $value}';
  }
}
