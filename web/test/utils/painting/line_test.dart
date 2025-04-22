import 'dart:math' as math;

import 'package:brew_kettle_dashboard/utils/painting/line.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const double precision = 0.0001;
  group('Line Constructors', () {
    test('Default constructor', () {
      const line = Line(Offset(1, 2), Offset(3, 4));
      expect(line.start, const Offset(1, 2));
      expect(line.end, const Offset(3, 4));
    });

    test('fromStartPoint (horizontal)', () {
      final line = Line.fromStartPoint(const Offset(2, 3), 0, 5);
      expect(line.start, const Offset(2, 3));
      expect(line.end.dx, closeTo(7, precision));
      expect(line.end.dy, closeTo(3, precision));
    });

    test('fromStartPoint (vertical)', () {
      final line = Line.fromStartPoint(const Offset(2, 3), math.pi / 2, 5);
      expect(line.start, const Offset(2, 3));
      expect(line.end.dx, closeTo(2, precision));
      expect(line.end.dy, closeTo(8, precision));
    });

    test('fromEndPoint (horizontal)', () {
      final line = Line.fromEndPoint(const Offset(7, 3), 0, 5);
      expect(line.end, const Offset(7, 3));
      expect(line.start.dx, closeTo(2, precision));
      expect(line.start.dy, closeTo(3, precision));
    });

    test('fromCenterPoint (horizontal)', () {
      final line = Line.fromCenterPoint(const Offset(5, 5), 0, 10);
      expect(line.start, const Offset(0, 5));
      expect(line.end, const Offset(10, 5));
    });

    test('vertical constructor', () {
      final line = Line.vertical(const Offset(2, 3), 4);
      expect(line.start, const Offset(2, 3));
      expect(line.end, const Offset(2, 7));
    });

    test('horizontal constructor', () {
      final line = Line.horizontal(const Offset(2, 3), 4);
      expect(line.start, const Offset(2, 3));
      expect(line.end, const Offset(6, 3));
    });
  });

  group('Line angle', () {
    test('angle calculation', () {
      expect(Line.horizontal(const Offset(0, 0), 5).angle, closeTo(0, precision));
      expect(Line.vertical(const Offset(0, 0), 5).angle, closeTo(math.pi / 2, precision));

      final diagonal = Line(const Offset(0, 0), const Offset(1, 1));
      expect(diagonal.angle, closeTo(math.pi / 4, precision));
    });
  });

  group('Line length', () {
    test('length calculation', () {
      expect(Line.horizontal(const Offset(0, 0), 5).length, closeTo(5, precision));
      expect(Line.vertical(const Offset(0, 0), 5).length, closeTo(5, precision));

      final line = Line(const Offset(0, 0), const Offset(3, 4));
      expect(line.length, closeTo(5, precision));
    });
    test('zero-length line', () {
      final line = Line.fromStartPoint(const Offset(2, 3), math.pi / 4, 0);
      expect(line.start, line.end);
      expect(line.length, closeTo(0, precision));
    });

    test('horizontal line length', () {
      final line = Line.horizontal(const Offset(0, 0), 5);
      expect(line.start, const Offset(0, 0));
      expect(line.end, const Offset(5, 0));
      expect(line.length, closeTo(5, precision));
    });

    test('horizontal line with negative length', () {
      final line = Line.horizontal(const Offset(0, 0), -5);
      expect(line.start, const Offset(0, 0));
      expect(line.end, const Offset(-5, 0));
      expect(line.length, closeTo(5, precision));
    });

    test('vertical line length', () {
      final line = Line.vertical(const Offset(0, 0), 5);
      expect(line.start, const Offset(0, 0));
      expect(line.end, const Offset(0, 5));
      expect(line.length, closeTo(5, precision));
    });

    test('vertical line with negative length', () {
      final line = Line.vertical(const Offset(0, 0), -5);
      expect(line.start, const Offset(0, 0));
      expect(line.end, const Offset(0, -5));
      expect(line.length, closeTo(5, precision));
    });
  });

  group('Line Operations', () {
    test('rotation around center', () {
      final original = Line.fromCenterPoint(const Offset(5, 5), 0, 10);
      final rotated = original.rotated(math.pi / 2, const Offset(5, 5));

      expect(rotated.start.dx, closeTo(5, precision));
      expect(rotated.start.dy, closeTo(0, precision));
      expect(rotated.end.dx, closeTo(5, precision));
      expect(rotated.end.dy, closeTo(10, precision));
    });

    test('rotation around origin', () {
      final line = Line(const Offset(1, 0), const Offset(2, 0));
      final rotated = line.rotated(math.pi / 2, const Offset(0, 0));

      expect(rotated.start.dx, closeTo(0, precision));
      expect(rotated.start.dy, closeTo(1, precision));
      expect(rotated.end.dx, closeTo(0, precision));
      expect(rotated.end.dy, closeTo(2, precision));
    });
  });

  group('Equality and HashCode', () {
    test('identical lines', () {
      final line1 = Line.horizontal(const Offset(0, 0), 5);
      final line2 = Line.fromStartPoint(const Offset(0, 0), 0, 5);
      expect(line1, equals(line2));
      expect(line1.hashCode, equals(line2.hashCode));
    });

    test('different lines', () {
      final line1 = Line.horizontal(const Offset(0, 0), 5);
      final line2 = Line.vertical(const Offset(0, 0), 5);
      expect(line1, isNot(equals(line2)));
    });
  });

  group(".Rotated", () {
    test('180 degree rotation', () {
      final original = Line.fromCenterPoint(const Offset(5, 5), math.pi / 4, 10);
      final rotated = original.rotated(math.pi, const Offset(5, 5));

      // Should reverse direction but maintain same positions
      expect(rotated.start.dx, closeTo(original.end.dx, precision));
      expect(rotated.start.dy, closeTo(original.end.dy, precision));

      expect(rotated.end.dx, closeTo(original.start.dx, precision));
      expect(rotated.end.dy, closeTo(original.start.dy, precision));
    });

    test('arbitrary rotation', () {
      final line = Line(const Offset(2, 2), const Offset(4, 4));
      final rotated = line.rotated(math.pi / 4, const Offset(3, 3));

      // Original line: diagonal from (2,2) to (4,4) (45° angle)
      // Rotating 45° clockwise (π/4) around center (3,3)
      // Should become vertical line through center
      final expectedStart = Offset(3, 3 - math.sqrt(2));
      final expectedEnd = Offset(3, 3 + math.sqrt(2));

      expect(rotated.start.dx, closeTo(expectedStart.dx, precision));
      expect(rotated.start.dy, closeTo(expectedStart.dy, precision));
      expect(rotated.end.dx, closeTo(expectedEnd.dx, precision));
      expect(rotated.end.dy, closeTo(expectedEnd.dy, precision));
    });

    test('zero rotation', () {
      final original = Line.horizontal(const Offset(0, 0), 5);
      final rotated = original.rotated(0, Offset.zero);
      expect(rotated, original);
    });
  });
}
