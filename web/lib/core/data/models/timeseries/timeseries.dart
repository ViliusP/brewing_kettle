import 'dart:collection';

class TimeSeries {
  UnmodifiableListView<TimeSeriesEntry> get data => UnmodifiableListView(
        _data,
      );

  final List<TimeSeriesEntry> _data;

  TimeSeries() : _data = [];

  TimeSeries.from(Iterable<TimeSeriesEntry> iterable)
      : _data = List<TimeSeriesEntry>.from(iterable);

  void add(TimeSeriesEntry entry) {
    _data.add(entry);
  }

  void addAll(List<TimeSeriesEntry> entry) {
    _data.addAll(entry);
  }

  List<TimeseriesViewEntry> aggregate({
    required AggregationType type,
    required AggregationInterval interval,
    MissingValueHandler? missingValueHandler,
  }) {
    final List<TimeseriesViewEntry> aggregated = [];
    final int intervalInMs = interval.milliseconds;

    final Map<int, List<num>> buckets = {};

    for (final entry in _data) {
      final int bucket = entry.date.millisecondsSinceEpoch ~/ intervalInMs;
      if (!buckets.containsKey(bucket)) {
        buckets[bucket] = [];
      }
      buckets[bucket]!.add(entry.value);
    }

    for (final bucket in buckets.keys) {
      final List<num> values = buckets[bucket]!;
      num? value = switch (type) {
        AggregationType.median => _median(values),
        AggregationType.mean => _mean(values),
        AggregationType.max => _max(values),
        AggregationType.min => _min(values),
        AggregationType.sum => _sum(values),
      };

      if (value == null) {
        switch (missingValueHandler) {
          case ValueFillerHandler valueFillerHandler:
            value = valueFillerHandler.value;
            break;
          case null:
            throw ArgumentError('Values list cannot be empty');
        }
      }
      aggregated.add(TimeseriesViewEntry(
        DateTime.fromMillisecondsSinceEpoch(bucket * intervalInMs),
        value,
      ));
    }

    return aggregated;
  }

  num? _mean(List<num> values) {
    if (values.isEmpty) return null;
    return (values.reduce((a, b) => (a + b)) / values.length);
  }

  num? _median(List<num> values) {
    if (values.isEmpty) return null;
    final sorted = List<num>.from(values)..sort();
    final mid = sorted.length ~/ 2;

    if (sorted.length.isOdd) {
      return sorted[mid];
    } else {
      return ((sorted[mid - 1] + sorted[mid]) / 2);
    }
  }

  num? _max(List<num> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

  num? _min(List<num> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a < b ? a : b);
  }

  num? _sum(List<num> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimeSeries && _data == other._data;
  }

  @override
  int get hashCode => _data.hashCode;
}

sealed class MissingValueHandler {
  MissingValueHandler();
}

class ValueFillerHandler extends MissingValueHandler {
  final num? value;

  ValueFillerHandler(this.value);
}

class TimeseriesViewEntry {
  final DateTime date;
  final num? value;

  TimeseriesViewEntry(this.date, [this.value]);

  @override
  String toString() {
    return 'TimeSeriesEntry{date: $date, value: $value}';
  }
}

class TimeSeriesEntry implements TimeseriesViewEntry {
  @override
  final DateTime date;

  @override
  covariant num value;

  TimeSeriesEntry(this.date, this.value);

  @override
  String toString() {
    return 'TimeSeriesEntry{date: $date, value: $value}';
  }
}

class AggregationInterval {
  final int value;
  final TimeUnit unit;

  const AggregationInterval._(this.unit, [this.value = 1]) : assert(value > 0);

  factory AggregationInterval.seconds([int value = 1]) => AggregationInterval._(
        TimeUnit.seconds,
        value,
      );

  factory AggregationInterval.minutes([int value = 1]) => AggregationInterval._(
        TimeUnit.minute,
        value,
      );

  factory AggregationInterval.hours([int value = 1]) => AggregationInterval._(
        TimeUnit.hour,
        value,
      );

  factory AggregationInterval.days([int value = 1]) => AggregationInterval._(
        TimeUnit.day,
        value,
      );

  factory AggregationInterval.weeks([int value = 1]) => AggregationInterval._(
        TimeUnit.week,
        value,
      );

  factory AggregationInterval.month([int value = 1]) => AggregationInterval._(
        TimeUnit.month,
        value,
      );

  factory AggregationInterval.year([int value = 1]) => AggregationInterval._(
        TimeUnit.year,
        value,
      );

  int get milliseconds => switch (unit) {
        TimeUnit.seconds => value * 1000,
        TimeUnit.minute => value * 1000 * 60,
        TimeUnit.hour => value * 1000 * 60 * 60,
        TimeUnit.day => value * 1000 * 60 * 60 * 24,
        TimeUnit.week => value * 1000 * 60 * 60 * 24 * 7,
        TimeUnit.month => value * 1000 * 60 * 60 * 24 * 30,
        TimeUnit.year => value * 1000 * 60 * 60 * 24 * 365,
      };

  @override
  String toString() =>
      'Every $value ${unit.toString().split('.').last}${value > 1 ? 's' : ''}';
}

enum AggregationType {
  mean,
  median,
  max,
  min,
  sum,
}

enum TimeUnit {
  seconds,
  minute,
  hour,
  day,
  week,
  month,
  year,
}
