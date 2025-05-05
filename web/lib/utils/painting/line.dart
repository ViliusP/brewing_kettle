import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// The [Line] class represents a line segment defined by two points: [start] and [end].
/// It provides methods to create lines from different points (start, end, center)
/// and perform basic geometric operations like rotation.
class Line {
  /// The starting point of the line segment.
  final Offset start;

  /// The ending point of the line segment.
  final Offset end;

  /// Creates a [Line] segment from a [start] and [end] points.
  const Line(this.start, this.end);

  /// Creates a [Line] starting from [start] with a given [angle] and [length].
  ///
  /// The [angle] is in radians, measured counter-clockwise from the positive x-axis.
  /// The [length] is the distance from the [start] point to the calculated [end] point.
  Line.fromStartPoint(this.start, double angle, double length)
    : end = Offset(start.dx + length * math.cos(angle), start.dy + length * math.sin(angle));

  /// Creates a [Line] ending at [end] with a given [angle] and [length].
  ///
  /// The [angle] is in radians, measured counter-clockwise from the positive x-axis.
  /// The [length] is the distance from the [end] point to the calculated [start] point.
  Line.fromEndPoint(this.end, double angle, double length)
    : start = Offset(end.dx - length * math.cos(angle), end.dy - length * math.sin(angle));

  /// Creates a [Line] centered at [center] with a given [angle] and total [length].
  ///
  /// The [angle] is in radians.
  /// The [start] and [end] points are calculated by extending half of the [length]
  /// in opposite directions along the given [angle] from the [center].
  Line.fromCenterPoint(Offset center, double angle, double length)
    : start = Offset(
        center.dx - length * math.cos(angle) / 2,
        center.dy - length * math.sin(angle) / 2,
      ),
      end = Offset(
        center.dx + length * math.cos(angle) / 2,
        center.dy + length * math.sin(angle) / 2,
      );

  /// Creates a vertical [Line] starting from [start] with a given [length].
  Line.vertical(this.start, double length) : end = Offset(start.dx, start.dy + length);

  /// Creates a horizontal [Line] starting from [start] with a given [length].
  Line.horizontal(this.start, double length) : end = Offset(start.dx + length, start.dy);

  /// Returns the angle of the line in radians.
  ///
  /// The angle is measured counter-clockwise from the positive x-axis.
  double get angle {
    return math.atan2(end.dy - start.dy, end.dx - start.dx);
  }

  /// Returns the length of the line segment.
  double get length {
    return (end - start).distance;
  }

  /// Returns a new [Line] rotated around the given [axis] point by the specified [angle] in radians.
  Line rotated(double angle, Offset axis) {
    final double cosAngle = math.cos(angle);
    final double sinAngle = math.sin(angle);

    final Offset newStart = Offset(
      axis.dx + (start.dx - axis.dx) * cosAngle - (start.dy - axis.dy) * sinAngle,
      axis.dy + (start.dx - axis.dx) * sinAngle + (start.dy - axis.dy) * cosAngle,
    );

    final Offset newEnd = Offset(
      axis.dx + (end.dx - axis.dx) * cosAngle - (end.dy - axis.dy) * sinAngle,
      axis.dy + (end.dx - axis.dx) * sinAngle + (end.dy - axis.dy) * cosAngle,
    );

    return Line(newStart, newEnd);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Line && runtimeType == other.runtimeType && start == other.start && end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() {
    return 'Line(start: $start, end: $end)';
  }
}
