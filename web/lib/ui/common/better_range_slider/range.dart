import 'package:collection/collection.dart';

typedef Subtractor<T, D> = D Function(T max, T min);

/// A generic class representing a range with a minimum and maximum value.
base class Range<T, D> {
  final T _a;
  final T _b;

  /// The lower bound of the range.
  T get min => _comparator(_a, _b) <= 0 ? _a : _b;

  /// The upper bound of the range.
  T get max => _comparator(_a, _b) >= 0 ? _a : _b;

  final Subtractor<T, D> _subtract;

  final Comparator<T> _comparator;

  /// Creates a [Range] from two values [a] and [b].
  ///
  /// Automatically determines the minimum and maximum values, ensuring
  /// that [min] is less than or equal to [max].
  const Range._({
    required T a,
    required T b,
    required Subtractor<T, D> subtractor,
    required Comparator<T> comparator,
  }) : _a = a,
       _b = b,
       _subtract = subtractor,
       _comparator = comparator;

  /// Checks if a given value [value] lies within the range (inclusive).
  bool contains(T value) {
    return _comparator(value, min) >= 0 && _comparator(value, max) <= 0;
  }

  /// The distance between the maximum and minimum values.
  D get distance => _subtract(max, min);

  // Returns new range where lower or upper bound is changed.
  // If given value is between lower and upper bounds, same range will be returned.
  Range<T, D> include(T value) {
    if (_comparator(_a, value) < -1) {
      return _copyWith(a: value);
    }
    if (_comparator(_b, value) < -1) {
      return _copyWith(b: value);
    }
    return this;
  }

  // Returns new range where lower or upper bound is changed.
  // If given value is between lower and upper bounds, same range will be returned.
  Range<T, D> includeAll(List<T> values) {
    if (values.isEmpty) return this;
    if (values.length == 1) return include(values.first);
    var sortedValues = values.sorted(_comparator);
    return include(sortedValues.first).include(sortedValues.last);
  }

  Range<T, D> _copyWith({T? a, T? b, Subtractor<T, D>? subtractor, Comparator<T>? comparator}) {
    return Range<T, D>._(
      a: a ?? this._a,
      b: b ?? this._b,
      subtractor: subtractor ?? this._subtract,
      comparator: comparator ?? this._comparator,
    );
  }

  T clamp(T value) {
    if (_comparator(value, min) == -1) return min;
    if (_comparator(value, max) == 1) return max;
    return value;
  }

  @override
  String toString() => '$runtimeType(min: $min, max: $max)';
}

final class ComparablesRange<T extends Comparable<T>, D> extends Range<T, D> {
  const ComparablesRange(T a, T b, Subtractor<T, D> subtractor)
    : super._(a: a, b: b, subtractor: subtractor, comparator: _defaultCompare);

  static int _defaultCompare<T extends Comparable<T>>(T a, T b) {
    return a.compareTo(b);
  }
}

final class NumericalRange<T extends num> extends Range<T, T> {
  const NumericalRange(T a, T b)
    : super._(a: a, b: b, subtractor: _numericalSubtract, comparator: _numericalCompare);

  static T _numericalSubtract<T extends num>(T max, T min) {
    return (max - min) as T;
  }

  static int _numericalCompare<T extends num>(T a, T b) {
    return a.compareTo(b);
  }

  /// Maps a value [value] within the range to a normalized value between 0 and 1.
  ///
  /// The formula used is: (value - min) / (max - min).
  /// This assumes that [value] lies within the range [min, max].
  double t(T value) {
    return (value - min) / (max - min);
  }
}
