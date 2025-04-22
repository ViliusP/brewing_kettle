import 'package:flutter_test/flutter_test.dart';
import 'package:brew_kettle_dashboard/utils/painting/rect_symmetry.dart';
import 'package:brew_kettle_dashboard/utils/painting/line.dart';
import 'package:flutter/material.dart';

void main() {
  group('Central Symmetry', () {
    test('Center is the same as the rect center', () {
      final rect = Rect.fromLTRB(4, 4, 6, 6);
      final center = const Offset(5, 5);
      final result = RectSymmetry.centralSymmetrical(rect: rect, center: center);
      expect(result, rect);
    });

    test('Center outside the rect', () {
      final rect = Rect.fromLTRB(1, 2, 3, 4);
      final center = const Offset(0, 0);
      final expected = Rect.fromLTRB(-3, -4, -1, -2);
      final result = RectSymmetry.centralSymmetrical(rect: rect, center: center);
      expect(result.left, closeTo(expected.left, 1e-9));
      expect(result.top, closeTo(expected.top, 1e-9));
      expect(result.right, closeTo(expected.right, 1e-9));
      expect(result.bottom, closeTo(expected.bottom, 1e-9));
    });

    test('Rect is a single point', () {
      final rect = Rect.fromLTRB(2, 3, 2, 3);
      final center = const Offset(0, 0);
      final expected = Rect.fromLTRB(-2, -3, -2, -3);
      final result = RectSymmetry.centralSymmetrical(rect: rect, center: center);
      expect(result, expected);
    });

    test('Center at a corner of the rect', () {
      final rect = Rect.fromLTRB(0, 0, 2, 2);
      final center = const Offset(2, 2);
      final expected = Rect.fromLTRB(2, 2, 4, 4);
      final result = RectSymmetry.centralSymmetrical(rect: rect, center: center);
      expect(result.left, closeTo(expected.left, 1e-9));
      expect(result.top, closeTo(expected.top, 1e-9));
      expect(result.right, closeTo(expected.right, 1e-9));
      expect(result.bottom, closeTo(expected.bottom, 1e-9));
    });
  });

  group('Axial Symmetry', () {
    test('Reflect over horizontal axis (x-axis)', () {
      final axis = Line(const Offset(0, 0), const Offset(1, 0));
      final rect = Rect.fromLTRB(1, 2, 3, 4);
      final expected = Rect.fromLTRB(1, -4, 3, -2);
      final result = RectSymmetry.axialSymmetrical(rect: rect, axis: axis);
      expect(result.left, closeTo(expected.left, 1e-9));
      expect(result.top, closeTo(expected.top, 1e-9));
      expect(result.right, closeTo(expected.right, 1e-9));
      expect(result.bottom, closeTo(expected.bottom, 1e-9));
    });

    test('Reflect over vertical axis (y-axis)', () {
      final axis = Line(const Offset(0, 0), const Offset(0, 1));
      final rect = Rect.fromLTRB(1, 2, 3, 4);
      final expected = Rect.fromLTRB(-3, 2, -1, 4);
      final result = RectSymmetry.axialSymmetrical(rect: rect, axis: axis);
      expect(result.left, closeTo(expected.left, 1e-9));
      expect(result.top, closeTo(expected.top, 1e-9));
      expect(result.right, closeTo(expected.right, 1e-9));
      expect(result.bottom, closeTo(expected.bottom, 1e-9));
    });

    test('Reflect over diagonal axis (y=x)', () {
      final axis = Line(const Offset(0, 0), const Offset(1, 1));
      final rect = Rect.fromLTRB(1, 2, 3, 4);
      final expected = Rect.fromLTRB(2, 1, 4, 3);
      final result = RectSymmetry.axialSymmetrical(rect: rect, axis: axis);
      expect(result.left, closeTo(expected.left, 1e-9));
      expect(result.top, closeTo(expected.top, 1e-9));
      expect(result.right, closeTo(expected.right, 1e-9));
      expect(result.bottom, closeTo(expected.bottom, 1e-9));
    });

    test('Axis is a single point (point reflection)', () {
      final axis = Line(const Offset(2, 3), const Offset(2, 3));
      final rect = Rect.fromLTRB(1, 1, 3, 5);
      final expected = Rect.fromLTRB(1, 1, 3, 5);
      final result = RectSymmetry.axialSymmetrical(rect: rect, axis: axis);
      expect(result, expected);
    });

    test('Axis coincides with rect edge', () {
      final axis = Line(const Offset(0, 0), const Offset(0, 2));
      final rect = Rect.fromLTRB(0, 0, 2, 2);
      final expected = Rect.fromLTRB(-2, 0, 0, 2);
      final result = RectSymmetry.axialSymmetrical(rect: rect, axis: axis);
      expect(result.left, closeTo(expected.left, 1e-9));
      expect(result.top, closeTo(expected.top, 1e-9));
      expect(result.right, closeTo(expected.right, 1e-9));
      expect(result.bottom, closeTo(expected.bottom, 1e-9));
    });

    test('Rect with zero width (vertical line)', () {
      final rect = Rect.fromLTRB(1, 2, 1, 4);
      final axis = Line(const Offset(0, 3), const Offset(1, 3));
      final result = RectSymmetry.axialSymmetrical(rect: rect, axis: axis);
      expect(result, rect);
    });

    test('Rect with zero height (horizontal line)', () {
      final rect = Rect.fromLTRB(1, 2, 3, 2);
      final axis = Line(const Offset(2, 0), const Offset(2, 1));
      final result = RectSymmetry.axialSymmetrical(rect: rect, axis: axis);
      expect(result, rect);
    });
  });
}
