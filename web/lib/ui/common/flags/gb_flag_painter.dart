import 'package:brew_kettle_dashboard/utils/painting_utilities.dart';
import 'package:flutter/rendering.dart';

class GbFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect canvasRect = Rect.fromLTWH(0, 0, size.width, size.height);

    Rect rectBlueSquare = Rect.fromLTWH(
      0,
      0,
      size.width * (0.5 - 0.05 - (0.05 / 2)),
      size.height * (0.5 - 0.05 - 0.1),
    );
    Paint rectBlueSquarePaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = Color(0xff012169);
    canvas.drawRect(rectBlueSquare, rectBlueSquarePaint);

    /// Bottom left square
    canvas.drawRect(
      RectSymmetry.axialSymmetrical(
        rect: rectBlueSquare,
        axis: Line(canvasRect.centerLeft, canvasRect.centerRight),
      ),
      rectBlueSquarePaint,
    );

    /// Bottom right square
    canvas.drawRect(
      RectSymmetry.centralSymmetrical(rect: rectBlueSquare, center: canvasRect.center),
      rectBlueSquarePaint,
    );

    /// Top right square
    canvas.drawRect(
      RectSymmetry.axialSymmetrical(
        rect: RectSymmetry.centralSymmetrical(rect: rectBlueSquare, center: canvasRect.center),
        axis: Line(canvasRect.centerLeft, canvasRect.centerRight),
      ),
      rectBlueSquarePaint,
    );

    Path path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width, size.height);
    path1.moveTo(size.width, 0);
    path1.lineTo(0, size.height);

    Paint paint1Stroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.1000000;
    paint1Stroke.color = Color.fromARGB(255, 255, 255, 255);
    canvas.drawPath(path1, paint1Stroke);

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = Color.fromARGB(255, 0, 0, 0);
    canvas.drawPath(path1, paint1Fill);

    Path path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(size.width, size.height);
    path2.moveTo(size.width, 0);
    path2.lineTo(0, size.height);

    Paint paint2Stroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.06666667;
    paint2Stroke.color = Color(0xffC8102E).withOpacity(1.0);
    canvas.drawPath(path2, paint2Stroke);

    Paint paint2Fill = Paint()..style = PaintingStyle.fill;
    paint2Fill.color = Color.fromARGB(255, 0, 0, 0);
    canvas.drawPath(path2, paint2Fill);

    Path path3 = Path();
    path3.moveTo(size.width * 0.5000000, 0);
    path3.lineTo(size.width * 0.5000000, size.height);
    path3.moveTo(0, size.height * 0.5000000);
    path3.lineTo(size.width, size.height * 0.5000000);

    Paint paint3Stroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.1666667;
    paint3Stroke.color = Color(0xffffffff).withOpacity(1.0);
    canvas.drawPath(path3, paint3Stroke);

    Paint paint3Fill = Paint()..style = PaintingStyle.fill;
    paint3Fill.color = Color.fromARGB(255, 0, 0, 0);
    canvas.drawPath(path3, paint3Fill);

    Path path4 = Path();
    path4.moveTo(size.width * 0.5000000, 0);
    path4.lineTo(size.width * 0.5000000, size.height);
    path4.moveTo(0, size.height * 0.5000000);
    path4.lineTo(size.width, size.height * 0.5000000);

    Paint paint4Stroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.1000000;
    paint4Stroke.color = Color(0xffC8102E).withOpacity(1.0);
    canvas.drawPath(path4, paint4Stroke);

    Paint paint4Fill = Paint()..style = PaintingStyle.fill;
    paint4Fill.color = Color.fromARGB(255, 0, 0, 0);
    canvas.drawPath(path4, paint4Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
