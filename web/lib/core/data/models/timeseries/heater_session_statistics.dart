import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';

class HeaterSessionStatistics {
  final double averageTemperature;
  // The lowest temperature recorded during the session
  final double lowestTemperature;
  // The highest temperature recorded during the session
  final double highestTemperature;

  // The average power consumed during the session in percentage (0-100)
  final double averagePower;

  // The average power consumed during the session in percentage (0-100)
  final double averageNonIdlePower;

  final Duration sessionDuration;
  final DateTime sessionStart;
  final DateTime sessionEnd;

  // The duration the heater was idle during the session
  final Duration idleDuration;

  // The duration the heater was not idle during the session
  final Duration activeDuration;

  const HeaterSessionStatistics({
    required this.averageTemperature,
    required this.lowestTemperature,
    required this.highestTemperature,
    required this.averagePower,
    required this.averageNonIdlePower,
    required this.sessionDuration,
    required this.sessionStart,
    required this.sessionEnd,
    required this.idleDuration,
    required this.activeDuration,
  });

  factory HeaterSessionStatistics.fromTimeseries(TimeSeries timeseries) {
    return HeaterSessionStatistics(
      averageTemperature: timeseries.meanByField("current_temperature") as double,
      lowestTemperature: timeseries.minByField("current_temperature") as double,
      highestTemperature: timeseries.maxByField("current_temperature") as double,
      averagePower: timeseries.meanByField("power") as double,
      averageNonIdlePower: timeseries.meanByField("power", _nonIdleStateSelector) as double,
      sessionDuration: timeseries.observationDuration,
      sessionStart: timeseries.data.first.date,
      sessionEnd: timeseries.data.last.date,
      idleDuration: timeseries.durationWhere(
        (e) => (e.value as HeaterControllerState).status == HeaterStatus.idle,
      ),
      activeDuration: timeseries.durationWhere(
        (e) =>
            (e.value as HeaterControllerState).status == HeaterStatus.heatingPid ||
            (e.value as HeaterControllerState).status == HeaterStatus.heatingManual,
      ),
    );
  }

  static bool _nonIdleStateSelector(dynamic e) {
    HeaterControllerState state = e.value as HeaterControllerState;
    return state.status != HeaterStatus.idle ? true : false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeaterSessionStatistics &&
          runtimeType == other.runtimeType &&
          averageTemperature == other.averageTemperature &&
          lowestTemperature == other.lowestTemperature &&
          highestTemperature == other.highestTemperature &&
          averagePower == other.averagePower &&
          averageNonIdlePower == other.averageNonIdlePower &&
          sessionDuration == other.sessionDuration &&
          sessionStart == other.sessionStart &&
          sessionEnd == other.sessionEnd &&
          idleDuration == other.idleDuration &&
          activeDuration == other.activeDuration;

  @override
  int get hashCode =>
      averageTemperature.hashCode ^
      lowestTemperature.hashCode ^
      highestTemperature.hashCode ^
      averagePower.hashCode ^
      averageNonIdlePower.hashCode ^
      sessionDuration.hashCode ^
      sessionStart.hashCode ^
      sessionEnd.hashCode ^
      idleDuration.hashCode ^
      activeDuration.hashCode;
}
