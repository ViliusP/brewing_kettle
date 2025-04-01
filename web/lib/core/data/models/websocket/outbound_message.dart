import 'dart:convert';

import 'package:brew_kettle_dashboard/utils/string_extensions.dart';
import 'package:uuid/uuid.dart';

abstract interface class ControllerMessagePayload {
  String get jsonString => json.encode(jsonMap);
  Map<String, dynamic> get jsonMap;
}

class WsOutboundMessage<T extends ControllerMessagePayload> {
  final String id;
  final OutboundMessageType type;
  final DateTime time;
  final T? payload;

  WsOutboundMessage({required this.id, required this.type, required this.time, this.payload});

  Map<String, dynamic> get jsonMap => {
    'id': id,
    'type': type.field,
    'time': time.millisecondsSinceEpoch,
    'payload': payload,
  };

  String get jsonString => json.encode(jsonMap);
}

class WsOutboundValueMessage extends WsOutboundMessage {
  final dynamic value;

  WsOutboundValueMessage({
    required super.id,
    required super.type,
    required super.time,
    required this.value,
  });

  @override
  Map<String, dynamic> get jsonMap => {
    'id': id,
    'type': type.field,
    'time': time.millisecondsSinceEpoch,
    'payload': {'value': value},
  };

  @override
  String get jsonString => json.encode(jsonMap);
}

class WsMessageComposer {
  static String simpleRequest(OutboundMessageType type) {
    return WsOutboundMessage(id: Uuid().v4(), type: type, time: DateTime.now()).jsonString;
  }

  static WsOutboundValueMessage requestStateChangeMessage(OutboundMessageType type, dynamic value) {
    return WsOutboundValueMessage(id: Uuid().v4(), type: type, time: DateTime.now(), value: value);
  }
}

enum OutboundMessageType {
  configurationGet("configuration_get"),
  snapshotGet("snapshot_get"),

  temperatureSet("temperature_set"),
  heaterModeSet("heater_mode_set"),
  pidConstantsSet("pid_constants_set"),

  powerSet("power_set");

  const OutboundMessageType([this._field]);

  final String? _field;

  String get field => _field ?? name.toSnakeCase();
}
