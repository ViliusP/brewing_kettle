import 'dart:math' as math;
import 'dart:ui';

import 'package:brew_kettle_dashboard/utils/painting/line.dart';

/// Provides methods for calculating symmetrical rectangles.
class RectSymmetry {
  /// Calculates the axial (line) symmetrical [Rect] for a given [rect]
  /// with respect to the given [axis] ([Line]).
  static Rect axialSymmetrical({required Rect rect, required Line axis}) {
    // Reflect each corner of the rectangle across the axis line.
    final Offset reflectedTopLeft = _reflectPointAcrossLine(rect.topLeft, axis);
    final Offset reflectedTopRight = _reflectPointAcrossLine(rect.topRight, axis);
    final Offset reflectedBottomRight = _reflectPointAcrossLine(rect.bottomRight, axis);
    final Offset reflectedBottomLeft = _reflectPointAcrossLine(rect.bottomLeft, axis);

    // Find the bounding box of the reflected corners to get the symmetrical rectangle.
    final double minX = math.min(
      math.min(reflectedTopLeft.dx, reflectedTopRight.dx),
      math.min(reflectedBottomRight.dx, reflectedBottomLeft.dx),
    );
    final double maxX = math.max(
      math.max(reflectedTopLeft.dx, reflectedTopRight.dx),
      math.max(reflectedBottomRight.dx, reflectedBottomLeft.dx),
    );
    final double minY = math.min(
      math.min(reflectedTopLeft.dy, reflectedTopRight.dy),
      math.min(reflectedBottomRight.dy, reflectedBottomLeft.dy),
    );
    final double maxY = math.max(
      math.max(reflectedTopLeft.dy, reflectedTopRight.dy),
      math.max(reflectedBottomRight.dy, reflectedBottomLeft.dy),
    );

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Calculates the central symmetrical [Rect] for a given [rect]
  /// with respect to the given [center] point.
  static Rect centralSymmetrical({required Rect rect, required Offset center}) {
    // The central symmetry of a rectangle with respect to a point
    // is another rectangle. The distance from the center to each side
    // of the original rectangle is maintained, but in the opposite direction.
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

  /// Calculates the projection of a [point] onto a [line].
  ///
  /// This is a helper function for axial symmetry.
  static Offset _projectPointOnLine(Offset point, Line line) {
    final Offset ap = point - line.start;
    final Offset ab = line.end - line.start;
    final double ab2 = ab.distanceSquared;

    // If the line is a single point, the projection is that point.
    if (ab2 == 0) {
      return line.start;
    }

    // Calculate the projection factor t.
    // t = dot(ap, ab) / |ab|^2
    // Manual dot product: ap.dx * ab.dx + ap.dy * ab.dy
    final double t = (ap.dx * ab.dx + ap.dy * ab.dy) / ab2;

    // The projected point is lineStart + t * ab
    return line.start + ab * t;
  }

  /// Reflects a [point] across the line.
  ///
  /// This is a helper function for axial symmetry.
  static Offset _reflectPointAcrossLine(Offset point, Line line) {
    // The reflection of a point P across a line L is P' such that the midpoint
    // of PP' is on L and PP' is perpendicular to L.
    // This means the projection of P onto L is the midpoint of PP'.
    // Let Proj(P) be the projection. Then (P + P') / 2 = Proj(P).
    // Solving for P': P' = 2 * Proj(P) - P.
    final Offset projection = _projectPointOnLine(point, line);
    return point + (projection - point) * 2;
  }
}
