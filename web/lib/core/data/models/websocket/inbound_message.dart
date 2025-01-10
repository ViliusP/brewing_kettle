import 'dart:collection';
import 'dart:convert';

import 'package:brew_kettle_dashboard/utils/string_extensions.dart';

part 'device_configuration.dart';
part 'device_snapshot.dart';

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

  const WsInboundMessageJson._(
    this._json,
    String data,
    Uri sender,
    DateTime time,
    this.requestID,
  ) : super._(data, sender, time);

  factory WsInboundMessageJson.create(
    Map<String, dynamic> json,
    String data,
    Uri sender,
  ) {
    String? requestID;
    bool hasRequestID = json.containsKey(_InboundMessageFields.requestID);
    if (hasRequestID) {
      requestID = json[_InboundMessageFields.requestID];
    }

    bool hasTypeField = json.containsKey(_InboundMessageFields.type);
    bool hasPayloadField = json.containsKey(_InboundMessageFields.payload);

    if (!(hasPayloadField && hasTypeField)) {
      return WsInboundMessageJson._(
        json,
        data,
        sender,
        DateTime.now(),
        requestID,
      );
    }

    final String rawType = json[_InboundMessageFields.type];
    final Map<String, dynamic> rawPayload = json[_InboundMessageFields.payload];

    try {
      final type = InboundMessageType.values.byName(rawType);

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
      return WsInboundMessageJson._(
        json,
        data,
        sender,
        DateTime.now(),
        requestID,
      );
    }
  }
}

sealed class WsInboundMessagePayload {
  WsInboundMessagePayload();

  factory WsInboundMessagePayload.fromJsonMap(
    Map<String, dynamic> json,
    InboundMessageType type,
  ) {
    return switch (type) {
      InboundMessageType.configuration => DeviceConfiguration.fromJson(json),
      InboundMessageType.snapshot => DeviceSnapshot.fromJson(json),
    };
  }
}

class WsInboundMessage<T extends WsInboundMessagePayload>
    extends WsInboundMessageJson {
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
  configuration("configuration"),
  snapshot("snapshot");

  const InboundMessageType([this._field]);

  final String? _field;

  String get field => _field ?? name.toSnakeCase();
}
