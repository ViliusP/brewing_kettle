import 'dart:math' as math;
import 'dart:ui';

/// The [Line] class represents a line segment defined by two points: [start] and [end].
/// It provides methods to create lines from different points (start, end, center)
class Line {
  /// The [start] point of the line.
  final Offset start;

  /// The [end] point of the line.
  final Offset end;

  const Line(this.start, this.end);

  /// Creates a line from the start point, given an angle and length.
  /// The angle is in radians, and the length is the distance from the start point.
  /// The end point is calculated based on the start point, angle, and length.
  /// The angle is measured counter-clockwise from the positive x-axis.
  /// The length is the distance from the start point to the end point.
  Line.fromStartPoint(this.start, double angle, double length)
    : end = Offset(start.dx + length * math.cos(angle), start.dy + length * math.sin(angle));

  /// Creates a line from the end point, given an angle and length.
  /// The angle is in radians, and the length is the distance from the end point.
  /// The start point is calculated based on the end point, angle, and length.
  /// The angle is measured counter-clockwise from the positive x-axis.
  /// The length is the distance from the end point to the start point.
  Line.fromEndPoint(this.end, double angle, double length)
    : start = Offset(end.dx - length * math.cos(angle), end.dy - length * math.sin(angle));

  /// Creates a line from a center point, given an angle and length.
  /// The angle is in radians, and the length is the distance from the center point.
  /// The start and end points are calculated based on the center point, angle, and length.
  /// The angle is measured counter-clockwise from the positive x-axis.
  /// The length is the distance from the center point to the start and end points.
  Line.fromCenterPoint(Offset center, double angle, double length)
    : start = Offset(
        center.dx - length * math.cos(angle) / 2,
        center.dy - length * math.sin(angle) / 2,
      ),
      end = Offset(
        center.dx + length * math.cos(angle) / 2,
        center.dy + length * math.sin(angle) / 2,
      );

  /// Creates a vertical line from a start point with a given length.
  Line.vertical(this.start, double length) : end = Offset(start.dx, start.dy + length);

  /// Creates a horizontal line from a start point with a given length.
  Line.horizontal(this.start, double length) : end = Offset(start.dx + length, start.dy);

  /// Returns the angle of the line in radians.
  double get angle {
    return math.atan2(end.dy - start.dy, end.dx - start.dx);
  }

  /// Returns the length of the line.
  double get length {
    return (end - start).distance;
  }

  /// Returns a new line rotated around the given [axis] by the specified [angle] in radians.
  Line rotate(double angle, Offset axis) {
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
}

class RectSymmetry {
  /// Calculates the axial (line) symmetrical Rect for a given [rect]
  /// with respect to the given [axis] (a [Line]).
  static Rect axialSymmetrical({required Rect rect, required Line axis}) {
    final Offset p1 = axis.start;
    final Offset p2 = axis.end;

    // Function to calculate the projection of a point onto the line
    Offset projectPointOnLine(Offset point, Offset lineStart, Offset lineEnd) {
      final Offset ap = point - lineStart;
      final Offset ab = lineEnd - lineStart;
      final double ab2 = ab.distanceSquared;
      if (ab2 == 0) return lineStart; // Line is a point
      final double dotProduct = ap.dx * ab.dx + ap.dy * ab.dy; // Manual dot product calculation
      final double t = dotProduct / ab2;
      return lineStart + ab * t;
    }

    // Function to reflect a point across the line
    Offset reflectPointAcrossLine(Offset point, Offset lineStart, Offset lineEnd) {
      final Offset projection = projectPointOnLine(point, lineStart, lineEnd);
      return point + (projection - point) * 2;
    }

    // Reflect all four corners of the rectangle
    final Offset reflectedTopLeft = reflectPointAcrossLine(rect.topLeft, p1, p2);
    final Offset reflectedTopRight = reflectPointAcrossLine(rect.topRight, p1, p2);
    final Offset reflectedBottomRight = reflectPointAcrossLine(rect.bottomRight, p1, p2);
    final Offset reflectedBottomLeft = reflectPointAcrossLine(rect.bottomLeft, p1, p2);

    // Find the bounding box of the reflected corners
    double minX = math.min(
      math.min(reflectedTopLeft.dx, reflectedTopRight.dx),
      math.min(reflectedBottomRight.dx, reflectedBottomLeft.dx),
    );
    double maxX = math.max(
      math.max(reflectedTopLeft.dx, reflectedTopRight.dx),
      math.max(reflectedBottomRight.dx, reflectedBottomLeft.dx),
    );
    double minY = math.min(
      math.min(reflectedTopLeft.dy, reflectedTopRight.dy),
      math.min(reflectedBottomRight.dy, reflectedBottomLeft.dy),
    );
    double maxY = math.max(
      math.max(reflectedTopLeft.dy, reflectedTopRight.dy),
      math.max(reflectedBottomRight.dy, reflectedBottomLeft.dy),
    );

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Calculates the central symmetrical Rect for a given [rect]
  /// with respect to the given [center] point.
  static Rect centralSymmetrical({required Rect rect, required Offset center}) {
    final double leftDistance = rect.left - center.dx;
    final double rightDistance = rect.right - center.dx;
    final double topDistance = rect.top - center.dy;
    final double bottomDistance = rect.bottom - center.dy;
    return Rect.fromLTRB(
      center.dx - rightDistance,
      center.dy - bottomDistance,
      center.dx - leftDistance,
      center.dy - topDistance,
    );
  }
}

extension OffsetRotation on Offset {
  Offset rotate(double angle) {
    final double cosAngle = math.cos(angle);
    final double sinAngle = math.sin(angle);
    return Offset(dx * cosAngle - dy * sinAngle, dx * sinAngle + dy * cosAngle);
  }
}
