part of 'inbound_message.dart';

/// Represents the PID constants (Proportional, Integral, Derivative) used in
/// control systems, received as part of a WebSocket inbound message.
///
/// These constants determine the behavior of a PID controller and must all be
/// valid non-null double values.
class PidConstants extends WsInboundMessagePayload {
  final double proportional;
  final double integral;
  final double derivative;

  /// Creates PID constants with fixed values
  const PidConstants({
    required this.proportional,
    required this.integral,
    required this.derivative,
  });

  /// Creates an instance from JSON payload
  ///
  /// Throws an exception if any of the required fields are missing or null
  factory PidConstants.fromJson(Map<String, dynamic> json) {
    final double? proportional = json["proportional"];
    final double? integral = json["integral"];
    final double? derivative = json["derivative"];

    if ([proportional, integral, derivative].contains(null)) {
      throw Exception("Cannot create PidConstants from $json");
    }

    return PidConstants(proportional: proportional!, integral: integral!, derivative: derivative!);
  }

  /// Equality operator compares all PID constants for value equality
  ///
  /// Returns true if all corresponding PID values are equal
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PidConstants &&
          runtimeType == other.runtimeType &&
          proportional == other.proportional &&
          integral == other.integral &&
          derivative == other.derivative;

  /// Generates a hash code based on the current PID values
  ///
  /// This ensures consistent hashing when used in collections
  @override
  int get hashCode => Object.hash(proportional, integral, derivative);
}
