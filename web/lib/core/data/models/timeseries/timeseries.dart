import 'dart:collection';

typedef TimeSeriesNumericsAccesor<T> = num Function(T value);
typedef TimeSeriesNumericAccesors<T> = Map<String, TimeSeriesNumericsAccesor<T>>;


// TODO explain _accesors

/// A class representing a time series of data entries.
/// Each entry consists of a date and a value.
/// The time series can be aggregated by different methods and intervals.
/// It can also be filtered by duration or date range.
///
/// Example:
/// ```dart
/// final timeSeries = TimeSeries.from([
///  TimeSeriesEntry(DateTime(2023, 1, 1), 1),
///  TimeSeriesEntry(DateTime(2023, 1, 2), 2),
///  TimeSeriesEntry(DateTime(2023, 1, 3), 3),
///  TimeSeriesEntry(DateTime(2023, 1, 4), 4),
/// ]);
///
/// print(timeSeries.observationDuration); // 3 days
///
/// final filtered = timeSeries.takeLastByDuration(Duration(days: 2));
/// print(filtered.data); // [TimeSeriesEntry(DateTime(2023, 1, 3), 3), TimeSeriesEntry(DateTime(2023, 1, 4), 4)]
///
/// final aggregated = timeSeries.aggregate(
///   defaultType: AggregationMethod.mean,
///   interval: AggregationInterval.days(1),
///   methodsByField: {
///     'temperature': AggregationMethod.mean,
///     'power': AggregationMethod.sum,
///   },
/// );
/// print(aggregated); // [TimeSeriesViewEntry(DateTime(2023, 1, 1), {'temperature': 1, 'power': 1}), ...]
/// ```
class TimeSeries<T> {
  UnmodifiableListView<TimeSeriesEntry<T>> get data => UnmodifiableListView(_data);

  final List<TimeSeriesEntry<T>> _data;
  final TimeSeriesNumericAccesors<T> _accesors;

  TimeSeries() : _data = [], _accesors = {};

  TimeSeries.from(Iterable<TimeSeriesEntry<T>> entries, TimeSeriesNumericAccesors<T> accesors)
    : _data = List<TimeSeriesEntry<T>>.from(entries),
      _accesors = accesors;

  /// The duration of the observation is the difference between the first and last entry date.
  /// If the data is empty, the duration is zero.
  /// If the data has only one entry, the duration is zero.
  /// If the data has more than one entry, the duration is the difference between the first and last entry date.
  /// Example:
  /// ```dart
  /// final timeSeries = TimeSeries.from([
  ///   TimeSeriesEntry(DateTime(2023, 1, 1), 1),
  ///   TimeSeriesEntry(DateTime(2023, 1, 2), 2),
  ///   TimeSeriesEntry(DateTime(2023, 1, 3), 3),
  ///   TimeSeriesEntry(DateTime(2023, 1, 4), 4),
  /// ]);
  /// print(timeSeries.observationDuration); // 3 days
  /// ```
  Duration get observationDuration {
    if (_data.length < 2) {
      return Duration.zero;
    }
    return _data.last.date.difference(_data.first.date);
  }

  void add(TimeSeriesEntry<T> entry) {
    _data.add(entry);
  }

  void addAll(List<TimeSeriesEntry<T>> entry) {
    _data.addAll(entry);
  }

  /// Returns a new [TimeSeries] with the same accesor but with the data filtered by the given duration.
  ///
  /// The reference date is the latest(last) entry of the [TimeSeries].
  ///
  /// If the duration is negative, an [ArgumentError] is thrown.
  /// If the duration is zero, the last entry is returned.
  /// If the data is empty, the original [TimeSeries] is returned.
  /// If the duration is greater than the data length, the original [TimeSeries] is returned.
  ///
  /// Example:
  /// ```dart
  /// final timeSeries = TimeSeries.from([
  ///  TimeSeriesEntry(DateTime(2023, 1, 1), 1),
  ///  TimeSeriesEntry(DateTime(2023, 1, 2), 2),
  ///  TimeSeriesEntry(DateTime(2023, 1, 3), 3),
  ///  TimeSeriesEntry(DateTime(2023, 1, 4), 4),
  /// ]);
  ///
  /// final filtered = timeSeries.takeLastByDuration(Duration(days: 2));
  /// print(filtered.data); // [TimeSeriesEntry(DateTime(2023, 1, 3), 3), TimeSeriesEntry(DateTime(2023, 1, 4), 4)]
  ///
  /// final filtered2 = timeSeries.takeLastByDuration(Duration(days: 0));
  /// print(filtered2.data); // [TimeSeriesEntry(DateTime(2023, 1, 4), 4)]
  /// ```
  TimeSeries<T> takeLastByDuration(Duration duration) {
    if (duration.isNegative) {
      throw ArgumentError('Duration cannot be negative');
    }
    if (_data.isEmpty) {
      return this;
    }

    if (duration == Duration.zero) {
      return TimeSeries.from([_data.last], _accesors);
    }

    if (duration > observationDuration) {
      return this;
    }

    return TimeSeries.from(
      _data.where((e) => e.date.isAfter(_data.last.date.subtract(duration))),
      _accesors,
    );
  }

  /// Returns a new TimeSeries with the same accesor but with the data filtered by the given range.
  ///
  /// If both [from] and [to] are null, or data is empty, the original TimeSeries is returned.
  /// If [from] is null, the data is filtered by the [to] date.
  /// If [to] is null, the data is filtered by the [from] date.
  /// If both are not null, the data is filtered by the [from] and [to] dates.
  ///
  /// The [from] and [to] dates are inclusive.
  /// If the [from] date is after the [to] date, an [ArgumentError] is thrown.
  ///
  /// Example:
  /// ```dart
  /// final timeSeries = TimeSeries.from([
  ///   TimeSeriesEntry(DateTime(2023, 1, 1), 1),
  ///   TimeSeriesEntry(DateTime(2023, 1, 2), 2),
  ///   TimeSeriesEntry(DateTime(2023, 1, 3), 3),
  ///   TimeSeriesEntry(DateTime(2023, 1, 4), 4),
  ///  ]);
  ///
  /// final filtered = timeSeries.takeByRange(DateTime(2023, 1, 2), DateTime(2023, 1, 3));
  /// print(filtered.data); // [TimeSeriesEntry(DateTime(2023, 1, 2), 2), TimeSeriesEntry(DateTime(2023, 1, 3), 3)]
  /// ```
  TimeSeries<T> takeByRange(DateTime? from, DateTime? to) {
    if ((from == null && to == null) || _data.isEmpty) {
      return this;
    }

    if (from != null) {
      return TimeSeries.from(_data.where((e) => e.date.isAfter(from)), _accesors);
    }
    if (to != null) {
      return TimeSeries.from(_data.where((e) => e.date.isBefore(to)), _accesors);
    }

    if (from!.isAfter(to!)) {
      throw ArgumentError('From date cannot be after to date');
    }

    return TimeSeries.from(
      _data.where((e) => e.date.isAfter(from) && e.date.isBefore(to)),
      _accesors,
    );
  }

  List<TimeSeriesViewEntry> aggregate({
    required AggregationMethod defaultType,
    required AggregationInterval interval,
    Map<String, AggregationMethod> methodsByField = const {},
    MissingValueHandler? missingValueHandler,
  }) {
    Map<String, List<TimeSeriesEntry<num>>> aggregatedFields = {};
    for (var accesorEntry in this._accesors.entries) {
      var field = accesorEntry.key;
      var accesor = accesorEntry.value;
      aggregatedFields[field] = _aggregateCollection(
        data: _data.map((e) => TimeSeriesEntry<num>(e.date, accesor(e.value))).toList(),
        method: methodsByField[field] ?? defaultType,
        interval: interval,
      );
    }

    int length = aggregatedFields.values.firstOrNull?.length ?? 0;
    List<TimeSeriesViewEntry> aggregatedData = [];

    for (var i in List.generate(length, (i) => i)) {
      Map<String, num> values = {};
      for (var key in this._accesors.keys) {
        values[key] = aggregatedFields[key]!.elementAt(i).value;
      }

      aggregatedData.add(TimeSeriesViewEntry(aggregatedFields.values.first[i].date, values));
    }
    return aggregatedData;
  }

  static List<TimeSeriesEntry<num>> _aggregateCollection({
    required List<TimeSeriesEntry<num>> data,
    required AggregationMethod method,
    required AggregationInterval interval,
    MissingValueHandler? missingValueHandler,
  }) {
    final List<TimeSeriesEntry<num>> aggregated = [];
    final int intervalInMs = interval.milliseconds;

    final Map<int, List<num>> buckets = {};

    for (final entry in data) {
      final int bucket = entry.date.millisecondsSinceEpoch ~/ intervalInMs;
      if (!buckets.containsKey(bucket)) {
        buckets[bucket] = [];
      }
      buckets[bucket]?.add(entry.value);
    }

    for (final bucket in buckets.keys) {
      final List<num> values = buckets[bucket]!;
      num? value = switch (method) {
        AggregationMethod.median => _median(values),
        AggregationMethod.mean => _mean(values),
        AggregationMethod.max => _max(values),
        AggregationMethod.min => _min(values),
        AggregationMethod.sum => _sum(values),
        AggregationMethod.first => _first(values),
        AggregationMethod.last => _last(values),
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
      aggregated.add(
        TimeSeriesEntry<num>(DateTime.fromMillisecondsSinceEpoch(bucket * intervalInMs), value!),
      );
    }

    return aggregated;
  }

  static num? _mean(List<num> values) {
    if (values.isEmpty) return null;
    return (values.reduce((a, b) => (a + b)) / values.length);
  }

  static num? _median(List<num> values) {
    if (values.isEmpty) return null;
    final sorted = List<num>.from(values)..sort();
    final mid = sorted.length ~/ 2;

    if (sorted.length.isOdd) {
      return sorted[mid];
    } else {
      return ((sorted[mid - 1] + sorted[mid]) / 2);
    }
  }

  static num? _max(List<num> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

  static num? _min(List<num> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a < b ? a : b);
  }

  static num? _sum(List<num> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b);
  }

  static num? _first(List<num> values) {
    if (values.isEmpty) return null;
    return values.firstOrNull;
  }

  static num? _last(List<num> values) {
    if (values.isEmpty) return null;
    return values.lastOrNull;
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

class TimeSeriesViewEntry {
  final DateTime date;
  final Map<String, num>? value;

  TimeSeriesViewEntry(this.date, [this.value]);

  @override
  String toString() {
    return 'TimeSeriesEntry{date: $date, value: $value}';
  }
}

class TimeSeriesEntry<T> {
  final DateTime date;

  covariant T value;

  TimeSeriesEntry(this.date, this.value);

  @override
  String toString() {
    return 'TimeSeriesEntry{date: $date, value: $value}';
  }
}

class AggregationInterval {
  static const int _hoursInDay = 24;

  static const int _daysInWeek = 7;
  static const int _daysInMonth = 30;
  static const int _daysInYear = 365;

  const AggregationInterval._(this.unit, [this.value = 1]) : assert(value > 0);

  const AggregationInterval.seconds([int value = 1]) : this._(TimeUnit.seconds, value);
  const AggregationInterval.minutes([int value = 1]) : this._(TimeUnit.minute, value);
  const AggregationInterval.hours([int value = 1]) : this._(TimeUnit.hour, value);
  const AggregationInterval.days([int value = 1]) : this._(TimeUnit.day, value);
  const AggregationInterval.weeks([int value = 1]) : this._(TimeUnit.week, value);
  const AggregationInterval.month([int value = 1]) : this._(TimeUnit.month, value);
  const AggregationInterval.year([int value = 1]) : this._(TimeUnit.year, value);

  final int value;
  final TimeUnit unit;

  int get milliseconds => switch (unit) {
    TimeUnit.milliseconds => value,
    TimeUnit.seconds => value * 1000,
    TimeUnit.minute => value * 1000 * 60,
    TimeUnit.hour => value * 1000 * 60 * 60,
    TimeUnit.day => value * 1000 * 60 * 60 * _hoursInDay,
    TimeUnit.week => value * 1000 * 60 * 60 * _hoursInDay * _daysInWeek,
    TimeUnit.month => value * 1000 * 60 * 60 * _hoursInDay * _daysInMonth,
    TimeUnit.year => value * 1000 * 60 * 60 * _hoursInDay * _daysInYear,
  };

  @override
  String toString() => 'Every $value ${unit.toString().split('.').last}${value > 1 ? 's' : ''}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AggregationInterval && value == other.value && unit == other.unit;
  }

  @override
  int get hashCode => value.hashCode ^ unit.hashCode;
}

enum AggregationMethod { mean, median, max, min, sum, first, last }

enum TimeUnit { milliseconds, seconds, minute, hour, day, week, month, year }
