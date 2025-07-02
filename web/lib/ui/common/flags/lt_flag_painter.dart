import 'package:flutter/rendering.dart';

class LtFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(0, 0);
    path_0.lineTo(size.width, 0);
    path_0.lineTo(size.width, size.height);
    path_0.lineTo(0, size.height);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Color(0xffBE3A34).withValues(alpha: 1.0);
    canvas.drawPath(path_0, paint0Fill);

    Path path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width, 0);
    path1.lineTo(size.width, size.height * 0.6666667);
    path1.lineTo(0, size.height * 0.6666667);
    path1.close();

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = Color(0xff046A38).withValues(alpha: 1.0);
    canvas.drawPath(path1, paint1Fill);

    Path path_2 = Path();
    path_2.moveTo(0, 0);
    path_2.lineTo(size.width, 0);
    path_2.lineTo(size.width, size.height * 0.3333333);
    path_2.lineTo(0, size.height * 0.3333333);
    path_2.close();

    Paint paint2Fill = Paint()..style = PaintingStyle.fill;
    paint2Fill.color = Color(0xffFFB81C).withValues(alpha: 1.0);
    canvas.drawPath(path_2, paint2Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
