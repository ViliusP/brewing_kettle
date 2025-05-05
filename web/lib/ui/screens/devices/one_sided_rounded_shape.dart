import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class OneSidedRoundedShape extends ShapeBorder {
  final AxisDirection roundedSide;
  final double radius;
  final BorderSide? baseBorderSide;

  const OneSidedRoundedShape({required this.roundedSide, this.radius = 16.0, this.baseBorderSide});

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    Paint paint = Paint();

    if (baseBorderSide != null) {
      paint
        ..color = baseBorderSide!.color
        ..strokeWidth = baseBorderSide!.width
        ..style = PaintingStyle.stroke;
    }

    final path = getOppositeSideBorderPath(rect); // Paint the entire outer path
    canvas.drawPath(path, paint);
  }

  BorderRadius borderRadiusForDirection() {
    switch (roundedSide) {
      case AxisDirection.up:
        return BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        );
      case AxisDirection.down:
        return BorderRadius.only(
          bottomLeft: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
      case AxisDirection.left:
        return BorderRadius.only(
          topLeft: Radius.circular(radius),
          bottomLeft: Radius.circular(radius),
        );
      case AxisDirection.right:
        return BorderRadius.only(
          topRight: Radius.circular(radius),
          bottomRight: Radius.circular(radius),
        );
    }
  }

  Path getOppositeSideBorderPath(Rect rect) {
    final Path path = Path();
    switch (roundedSide) {
      case AxisDirection.up:
        path.moveTo(rect.bottomLeft.dx, rect.bottomLeft.dy);
        path.lineTo(rect.bottomRight.dx, rect.bottomRight.dy);
        break;
      case AxisDirection.down:
        path.moveTo(rect.topLeft.dx, rect.topLeft.dy);
        path.lineTo(rect.topRight.dx, rect.topRight.dy);
        break;
      case AxisDirection.left:
        path.moveTo(rect.topRight.dx, rect.topRight.dy);
        path.lineTo(rect.bottomRight.dx, rect.bottomRight.dy);
        break;
      case AxisDirection.right:
        path.moveTo(rect.topLeft.dx, rect.topLeft.dy);
        path.lineTo(rect.bottomLeft.dx, rect.bottomLeft.dy);
        break;
    }
    return path;
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is OneSidedRoundedShape) {
      return OneSidedRoundedShape(
        roundedSide: roundedSide,
        radius: lerpDouble(a.radius, radius, t)!,
        baseBorderSide: _lerpBorderSide(a.baseBorderSide, baseBorderSide, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is OneSidedRoundedShape) {
      return OneSidedRoundedShape(
        roundedSide: roundedSide,
        radius: lerpDouble(radius, b.radius, t)!,
        baseBorderSide: _lerpBorderSide(baseBorderSide, b.baseBorderSide, t),
      );
    }
    return super.lerpTo(b, t);
  }

  BorderSide? _lerpBorderSide(BorderSide? a, BorderSide? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return BorderSide.lerp(b!, b, t);
    if (b == null) {
      return BorderSide.lerp(a, a, t);
    }
    return BorderSide.lerp(a, b, t);
  }

  @override
  ShapeBorder scale(double t) => OneSidedRoundedShape(
    roundedSide: roundedSide,
    radius: radius * t,
    baseBorderSide: baseBorderSide?.scale(t),
  );

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadiusForDirection().toRRect(rect));
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final double strokeWidth = (baseBorderSide?.width ?? 0);
    final Rect innerRect = rect.deflate(strokeWidth);
    return Path()..addRRect(borderRadiusForDirection().toRRect(innerRect));
  }
}
