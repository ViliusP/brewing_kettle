import 'package:flutter/rendering.dart';

class LvFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(size.width, 0);
    path0.lineTo(size.width, size.height);
    path0.lineTo(0, size.height);

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Color(0xff9D2235).withAlpha(255);
    canvas.drawPath(path0, paint0Fill);

    Path path1 = Path();
    path1.moveTo(0, size.height * 0.4000000);
    path1.lineTo(size.width, size.height * 0.4000000);
    path1.lineTo(size.width, size.height * 0.6000000);
    path1.lineTo(0, size.height * 0.6000000);

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = Color(0xffFFFFFF).withAlpha(255);
    canvas.drawPath(path1, paint1Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
