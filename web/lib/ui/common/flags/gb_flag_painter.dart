import 'package:brew_kettle_dashboard/utils/painting_utilities.dart';
import 'package:flutter/rendering.dart';

class GbFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect canvasRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // -----------------------------------
    // ---------- Blue squares -----------
    // -----------------------------------
    final Line horizontalSymmetryLine = Line(canvasRect.centerLeft, canvasRect.centerRight);

    final double whiteCrossHalfWidth = size.width * 0.1666667 / 2;

    final Rect rectBlueSquare = Rect.fromPoints(
      Offset.zero,
      Offset(
        size.width * 0.5,
        size.height * 0.5,
      ).translate(-whiteCrossHalfWidth, -whiteCrossHalfWidth),
    );

    final Paint rectBlueSquarePaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = Color.fromRGBO(1, 33, 105, 1);
    canvas.drawRect(rectBlueSquare, rectBlueSquarePaint);

    // Bottom left square
    canvas.drawRect(
      RectSymmetry.axialSymmetrical(rect: rectBlueSquare, axis: horizontalSymmetryLine),
      rectBlueSquarePaint,
    );

    // Bottom right square
    final Rect bottomRightBlueSquare = RectSymmetry.centralSymmetrical(
      rect: rectBlueSquare,
      center: canvasRect.center,
    );
    canvas.drawRect(bottomRightBlueSquare, rectBlueSquarePaint);

    // Top right square
    canvas.drawRect(
      RectSymmetry.axialSymmetrical(rect: bottomRightBlueSquare, axis: horizontalSymmetryLine),
      rectBlueSquarePaint,
    );

    // ------------------------------------
    // ------- White diagonal lines -------
    // ------------------------------------
    final Path whiteDiagonalsPath = Path();
    whiteDiagonalsPath.moveTo(0, 0);
    whiteDiagonalsPath.lineTo(size.width, size.height);
    whiteDiagonalsPath.moveTo(size.width, 0);
    whiteDiagonalsPath.lineTo(0, size.height);

    final Paint whiteDiagonalsPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.1000000;
    whiteDiagonalsPaint.color = Color.fromRGBO(255, 255, 255, 1);
    canvas.drawPath(whiteDiagonalsPath, whiteDiagonalsPaint);

    // ------------------------------------
    // -------- Red diagonal lines --------
    // ------------------------------------
    final Path redDiagonalsPath = Path();
    redDiagonalsPath.moveTo(0, 0);
    redDiagonalsPath.lineTo(size.width, size.height);
    redDiagonalsPath.moveTo(size.width, 0);
    redDiagonalsPath.lineTo(0, size.height);

    final Paint redDiagonalsPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.06666667;
    redDiagonalsPaint.color = Color.fromRGBO(200, 16, 46, 1);
    canvas.drawPath(redDiagonalsPath, redDiagonalsPaint);

    // ------------------------------------
    // ----------- White cross ------------
    // ------------------------------------
    final Path whiteCrossPath = Path();
    whiteCrossPath.moveTo(size.width * 0.5000000, 0);
    whiteCrossPath.lineTo(size.width * 0.5000000, size.height);
    whiteCrossPath.moveTo(0, size.height * 0.5000000);
    whiteCrossPath.lineTo(size.width, size.height * 0.5000000);

    final Paint whiteCrossPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.1666667;
    whiteCrossPaint.color = Color.fromRGBO(255, 255, 255, 1);
    canvas.drawPath(whiteCrossPath, whiteCrossPaint);

    // ------------------------------------
    // ------------ Red cross -------------
    // ------------------------------------
    final Path redCrossPath = Path();
    redCrossPath.moveTo(size.width * 0.5000000, 0);
    redCrossPath.lineTo(size.width * 0.5000000, size.height);
    redCrossPath.moveTo(0, size.height * 0.5000000);
    redCrossPath.lineTo(size.width, size.height * 0.5000000);

    final Paint redCrossPain =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.1000000;
    redCrossPain.color = Color.fromRGBO(200, 16, 46, 1);
    canvas.drawPath(redCrossPath, redCrossPain);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
