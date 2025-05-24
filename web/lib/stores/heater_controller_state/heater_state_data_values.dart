import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';

class HeaterStateHistoryValues {
  /// The minimum allowable data range interval.
  /// Defines the shortest time span of data that can be included,
  /// counted backward from the latest data point.
  static const Duration minDataInterval = Duration(minutes: 15);

  /// The maximum allowable data range interval.
  /// Defines the longest time span of data that can be included,
  /// counted backward from the latest data point.
  static const Duration maxDataInterval = Duration(hours: 5);

  /// The default data range interval.
  /// Used when no specific interval is provided.
  /// The time span is counted backward from the latest data point.
  static const Duration defaultDataDuration = Duration(hours: 1);

  /// The default interval used for aggregating data points.
  /// Determines the time span represented by each aggregated point.
  static const AggregationInterval defaultAggregationInterval = AggregationInterval.seconds(15);
}
