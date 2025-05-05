import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArcSliderPainter extends CustomPainter {
  ArcSliderPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.arcWidth,
    required this.color,
    this.progress = 0,
  });
  final double arcWidth;
  final double startAngle;
  final double sweepAngle;

  final double progress;
  final Color color;

  final rectPainter =
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Color.fromRGBO(255, 59, 59, 1)
        ..strokeWidth = 1
        ..strokeCap = StrokeCap.butt;

  final dotsPainter =
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Color.fromRGBO(255, 59, 59, 1)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final arcPainter =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromLTWH(
      arcWidth / 2,
      arcWidth / 2,
      size.width - arcWidth,
      size.height - arcWidth,
    );

    final outerArcRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final innerArcRect = Rect.fromLTWH(
      arcWidth,
      arcWidth,
      size.width - arcWidth * 2,
      size.height - arcWidth * 2,
    );

    final innerDotOffset = innerArcRect.width / 2;

    final innerArcStartPoint = Offset(
      innerArcRect.center.dx + innerDotOffset * math.cos(startAngle),
      innerArcRect.center.dy + innerDotOffset * math.sin(startAngle),
    );

    final innerArcEndPoint = Offset(
      innerArcRect.center.dx + innerDotOffset * math.cos(startAngle + sweepAngle),
      innerArcRect.center.dy + innerDotOffset * math.sin(startAngle + sweepAngle),
    );

    Offset canvasCenter = arcRect.center;

    // -----------

    final outerDotOffset = outerArcRect.width / 2;

    final outerArcStartPoint = Offset(
      canvasCenter.dx + outerDotOffset * math.cos(startAngle),
      canvasCenter.dy + outerDotOffset * math.sin(startAngle),
    );

    final outerArcEndPoint = Offset(
      canvasCenter.dx + outerDotOffset * math.cos(startAngle + sweepAngle),
      canvasCenter.dy + outerDotOffset * math.sin(startAngle + sweepAngle),
    );

    Path arcPath = Path();
    arcPath.arcTo(outerArcRect, startAngle, sweepAngle, true);
    arcPath.arcTo(innerArcRect, startAngle, sweepAngle, true);
    arcPath.moveTo(outerArcStartPoint.dx, outerArcStartPoint.dy);
    arcPath.arcToPoint(
      innerArcStartPoint,
      radius: Radius.circular(1),
      rotation: math.pi / 2,
      largeArc: true,
      clockwise: false,
    );

    // MAGIC

    final endOuterCornerEndPoint = polarTranslate(
      canvasCenter,
      outerArcEndPoint,
      angle: degreesToRadians(4),
      radiusDistance: 0,
    );

    final endInnerCornerEndPoint = polarTranslate(
      canvasCenter,
      innerArcEndPoint,
      angle: degreesToRadians(4),
      radiusDistance: 0,
    );

    final middleEndPoint = polarTranslate(
      canvasCenter,
      outerArcEndPoint,
      angle: degreesToRadians(4),
      radiusDistance: -arcWidth / 2,
    );
    arcPath.moveTo(outerArcEndPoint.dx, outerArcEndPoint.dy);

    double conicWeight = 2;

    arcPath.conicTo(
      endOuterCornerEndPoint.dx,
      endOuterCornerEndPoint.dy,
      middleEndPoint.dx,
      middleEndPoint.dy,
      conicWeight,
    );

    arcPath.conicTo(
      endInnerCornerEndPoint.dx,
      endInnerCornerEndPoint.dy,
      innerArcEndPoint.dx,
      innerArcEndPoint.dy,
      conicWeight,
    );

    arcPath.close();

    // arcPath.lineTo(endInnerCornerEndPoint.dx, endInnerCornerEndPoint.dy);

    // arcPath.moveTo(endInnerCornerEndPoint.dx, endInnerCornerEndPoint.dy);

    // arcPath.arcToPoint(
    //   innerArcEndPoint,
    //   radius: Radius.circular(4),
    //   clockwise: false,
    // );

    canvas.drawPath(arcPath, arcPainter);

    canvas.drawRect(outerArcRect, rectPainter);
    canvas.drawRect(innerArcRect, rectPainter);

    canvas.drawPoints(PointMode.points, [
      // innerArcStartPoint,
      // innerArcEndPoint,
      // outerArcStartPoint,
      // outerArcEndPoint,
      // endOuterCornerEndPoint,
      // middleEndPoint,
      // endInnerCornerEndPoint,
    ], dotsPainter);
    // canvas.drawArc(
    //   arcRect,
    //   startAngle,
    //   sweepAngle * progress / 100,
    //   false,
    //   arcPainter,
    // );
  }

  Offset polarTranslate(
    Offset center,
    Offset point, {
    double angle = 0,
    double radiusDistance = 0,
  }) {
    // Calculate the vector from the center to the point
    double deltaX = point.dx - center.dx;
    double deltaY = point.dy - center.dy;

    // Calculate the original distance (radius)
    double originalDistance = math.sqrt(deltaX * deltaX + deltaY * deltaY);

    // Calculate the original angle (atan2 handles all quadrants correctly)
    double originalAngle = math.atan2(deltaY, deltaX);

    // Apply the angle rotation (in radians)
    double newAngle = originalAngle + angle; // Convert degrees to radians

    // Calculate the new distance. This is the key change:
    double newDistance = originalDistance + radiusDistance;

    //Prevent from going to negative distance
    if (newDistance < 0) {
      newDistance = 0;
    }

    // Calculate the new x and y coordinates
    double newX = center.dx + newDistance * math.cos(newAngle);
    double newY = center.dy + newDistance * math.sin(newAngle);

    return Offset(newX, newY);
  }

  double degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  @override
  bool shouldRepaint(ArcSliderPainter oldDelegate) =>
      color != oldDelegate.color || progress != oldDelegate.progress;

  @override
  bool? hitTest(Offset position) {
    // Path path = Path();
    // path.addArc(oval, startAngle, sweepAngle)
    // TODO: implement hitTest
    return super.hitTest(position);
  }
}
