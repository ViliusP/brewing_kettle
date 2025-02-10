import 'dart:collection';

typedef TimeSeriesAccesor<T> = num Function(T value);
typedef TimeSeriesAccesors<T> = Map<String, TimeSeriesAccesor<T>>;

class TimeSeries<T> {
  UnmodifiableListView<TimeSeriesEntry<T>> get data => UnmodifiableListView(
        _data,
      );

  final List<TimeSeriesEntry<T>> _data;
  final TimeSeriesAccesors<T> _accesors;

  TimeSeries()
      : _data = [],
        _accesors = {};

  TimeSeries.from(
    Iterable<TimeSeriesEntry<T>> entries,
    TimeSeriesAccesors<T> accesors,
  )   : _data = List<TimeSeriesEntry<T>>.from(entries),
        _accesors = accesors;

  void add(TimeSeriesEntry<T> entry) {
    _data.add(entry);
  }

  void addAll(List<TimeSeriesEntry<T>> entry) {
    _data.addAll(entry);
  }

  List<TimeSeriesViewEntry> aggregate({
    required AggregationType defaultType,
    required AggregationInterval interval,
    Map<String, AggregationType> typesByField = const {},
    MissingValueHandler? missingValueHandler,
  }) {
    Map<String, List<TimeSeriesEntry<num>>> aggregatedFields = {};
    for (var accesorEntry in this._accesors.entries) {
      var field = accesorEntry.key;
      var accesor = accesorEntry.value;
      aggregatedFields[field] = _aggregateCollection(
        data: _data
            .map((e) => TimeSeriesEntry<num>(e.date, accesor(e.value)))
            .toList(),
        type: typesByField[field] ?? defaultType,
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

      aggregatedData.add(TimeSeriesViewEntry(
        aggregatedFields.values.first[i].date,
        values,
      ));
    }
    return aggregatedData;
  }

  static List<TimeSeriesEntry<num>> _aggregateCollection({
    required List<TimeSeriesEntry<num>> data,
    required AggregationType type,
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
      num? value = switch (type) {
        AggregationType.median => _median(values),
        AggregationType.mean => _mean(values),
        AggregationType.max => _max(values),
        AggregationType.min => _min(values),
        AggregationType.sum => _sum(values),
        AggregationType.first => _first(values),
        AggregationType.last => _last(values),
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
      aggregated.add(TimeSeriesEntry<num>(
        DateTime.fromMillisecondsSinceEpoch(bucket * intervalInMs),
        value!,
      ));
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
  first,
  last,
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
