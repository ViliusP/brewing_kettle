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
    final HeaterStatus? status = HeaterStatus.values.firstWhereOrNull(
      (v) => json["status"] == v.jsonValue,
    );

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is HeaterControllerState &&
        timestamp == other.timestamp &&
        status == other.status &&
        currentTemperature == other.currentTemperature &&
        targetTemperature == other.targetTemperature &&
        power == other.power;
  }

  @override
  int get hashCode => Object.hash(
        timestamp,
        status,
        currentTemperature,
        targetTemperature,
        power,
      );

  @override
  String toString() {
    return 'HeaterControllerState{timestamp: $timestamp, status: $status, currentTemperature: $currentTemperature, targetTemperature: $targetTemperature, power: $power}';
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

enum HeaterMode {
  idle("idle"),
  heatingManual("heating_manual"),
  heatingPid("heating_pid");

  const HeaterMode(this.jsonValue);

  final String jsonValue;

  HeaterStatus toHeaterStatus() => switch (this) {
        idle => HeaterStatus.idle,
        heatingManual => HeaterStatus.heatingManual,
        heatingPid => HeaterStatus.heatingPid,
      };

  static HeaterMode? fromHeaterStatus(HeaterStatus value) => switch (value) {
        HeaterStatus.idle => HeaterMode.idle,
        HeaterStatus.heatingManual => HeaterMode.heatingManual,
        HeaterStatus.heatingPid => HeaterMode.heatingPid,
        _ => null,
      };
}
