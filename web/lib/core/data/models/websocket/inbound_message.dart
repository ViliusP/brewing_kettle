import 'dart:convert';

import 'package:brew_kettle_dashboard/utils/string_extensions.dart';
import 'package:collection/collection.dart';

part 'device_snapshot.dart';
part 'message_simple_value.dart';
part 'heater_controller_state.dart';

/// Represents an inbound message received via WebSocket.
///
/// This model is used to parse and handle incoming WebSocket messages
/// within the application. It provides the necessary structure to
/// deserialize the JSON data received from the WebSocket connection.
///
/// The class includes fields to store the message data and methods
/// to process or manipulate the data as needed.
///
/// Example usage:
/// ```dart
/// final inboundMessage = InboundMessage.fromJson(jsonData);
/// print(inboundMessage.data);
/// ```
///
/// Make sure to handle any potential errors or exceptions that may
/// occur during the deserialization process to ensure the stability
/// of the application.
class WsInboundMessageSimple {
  final String data;
  final Uri sender;
  final DateTime time;

  const WsInboundMessageSimple._(this.data, this.sender, this.time);

  factory WsInboundMessageSimple.create(String data, Uri sender) {
    try {
      var decodedJSON = json.decode(data) as Map<String, dynamic>;
      return WsInboundMessageJson.create(decodedJSON, data, sender);
    } catch (e) {
      return WsInboundMessageSimple._(data, sender, DateTime.now());
    }
  }

  Map<String, dynamic> get asJsonMap {
    return {}..addEntries([
      MapEntry("time", time.toString()),
      MapEntry("sender", sender.toString()),
      MapEntry("data", data),
    ]);
  }

  WsInboundMessageSimple copyWith({String? data, Uri? sender, DateTime? time}) {
    return WsInboundMessageSimple._(data ?? this.data, sender ?? this.sender, time ?? this.time);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WsInboundMessageSimple &&
        data == other.data &&
        sender == other.sender &&
        time == other.time;
  }

  @override
  int get hashCode => Object.hash(data, sender, time);

  @override
  String toString() {
    return 'WsInboundMessageSimple{data: $data, sender: $sender, time: $time}'; // Useful for debugging
  }
}

class _InboundMessageFields {
  static const type = "type";
  static const payload = "payload";
  static const requestID = "request_id";
}

/// This file defines the `InboundMessage` model for handling incoming WebSocket messages.
///
/// The `InboundMessage` class is used to parse and manage data received from WebSocket connections.
/// It includes properties and methods to facilitate the processing of inbound messages in the application.
class WsInboundMessageJson extends WsInboundMessageSimple {
  final String? requestID;

  UnmodifiableMapView<String, dynamic> get json => UnmodifiableMapView(_json);
  final Map<String, dynamic> _json;

  const WsInboundMessageJson._(this._json, String data, Uri sender, DateTime time, this.requestID)
    : super._(data, sender, time);

  factory WsInboundMessageJson.create(Map<String, dynamic> json, String data, Uri sender) {
    String? requestID;
    bool hasRequestID = json.containsKey(_InboundMessageFields.requestID);
    if (hasRequestID) {
      requestID = json[_InboundMessageFields.requestID];
    }

    bool hasTypeField = json.containsKey(_InboundMessageFields.type);
    bool hasPayloadField = json.containsKey(_InboundMessageFields.payload);

    if (!(hasPayloadField && hasTypeField)) {
      return WsInboundMessageJson._(json, data, sender, DateTime.now(), requestID);
    }

    final String rawType = json[_InboundMessageFields.type];
    final Map<String, dynamic> rawPayload = json[_InboundMessageFields.payload];

    try {
      final type = InboundMessageType.values.firstWhereOrNull((m) => m.field == rawType);
      if (type == null) {
        return WsInboundMessageJson._(json, data, sender, DateTime.now(), requestID);
      }

      final payload = WsInboundMessagePayload.fromJsonMap(rawPayload, type);
      return WsInboundMessage._(
        type: type,
        payload: payload,
        json: json,
        data: data,
        sender: sender,
        time: DateTime.now(),
        requestID: requestID,
      );
    } catch (e) {
      return WsInboundMessageJson._(json, data, sender, DateTime.now(), requestID);
    }
  }

  @override
  Map<String, dynamic> get asJsonMap {
    return {}..addEntries([
      MapEntry("time", time.toString()),
      MapEntry("sender", sender.toString()),
      MapEntry("data", _json),
    ]);
  }
}

sealed class WsInboundMessagePayload {
  const WsInboundMessagePayload();

  factory WsInboundMessagePayload.fromJsonMap(Map<String, dynamic> json, InboundMessageType type) {
    return switch (type) {
      InboundMessageType.snapshot => DeviceSnapshot.fromJson(json),
      InboundMessageType.heaterControllerState => HeaterControllerState.fromJson(json),
    };
  }
}

class WsInboundMessage<T extends WsInboundMessagePayload> extends WsInboundMessageJson {
  final InboundMessageType type;
  final T payload;

  const WsInboundMessage._({
    required this.type,
    required this.payload,
    required Map<String, dynamic> json,
    required String data,
    required Uri sender,
    required DateTime time,
    required String? requestID,
  }) : super._(json, data, sender, time, requestID);
}

enum InboundMessageType {
  snapshot("snapshot"),
  heaterControllerState("heater_controller_state");

  const InboundMessageType([this._field]);

  final String? _field;

  String get field => _field ?? name.toSnakeCase();
}
