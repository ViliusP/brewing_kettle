part of 'inbound_message.dart';

class HeaterControllerState extends WsInboundMessagePayload {
  final int timestamp;
  final HeaterStatus status;
  final double currentTemperature;
  final double targetTemperature;
  final double power;

  HeaterControllerState({
    required this.timestamp,
    required this.status,
    required this.currentTemperature,
    required this.targetTemperature,
    required this.power,
  });

  factory HeaterControllerState.fromJson(Map<String, dynamic> json) {
    final int? timestamp = json["timestamp"];
    final num? currentTemperature = json["current_temperature"];
    final num? targetTemperature = json["target_temperature"];
    final num? power = json["power"];
    final HeaterStatus? status = HeaterStatus.values.byNameSafe(json["status"]);

    if ([
      timestamp,
      currentTemperature,
      targetTemperature,
      power,
      status,
    ].contains(null)) {
      throw Exception("Cannot create HeaterControllerState from $json");
    }

    return HeaterControllerState(
      status: status!,
      currentTemperature: currentTemperature!.toDouble(),
      targetTemperature: targetTemperature!.toDouble(),
      power: power!.toDouble(),
      timestamp: timestamp!,
    );
  }
}

enum HeaterStatus {
  idle("idle"),
  heatingManual("heating_manual"),
  heatingPid("heating_pid"),
  error("error"),
  unknown("unknown");

  const HeaterStatus(this.jsonValue);

  final String jsonValue;
}
