import 'package:flutter/rendering.dart';

class GbFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(0, size.height);
    path0.lineTo(size.width, size.height);
    path0.lineTo(size.width, 0);
    path0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = Color(0xff012169).withOpacity(1.0);
    canvas.drawPath(path0, paint0Fill);

    Path path1 = Path();
    path1.moveTo(0, 0);
    path1.lineTo(size.width, size.height);
    path1.moveTo(size.width, 0);
    path1.lineTo(0, size.height);

    Paint paint1Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1000000;
    paint1Stroke.color = Color(0xffffffff).withOpacity(1.0);
    canvas.drawPath(path1, paint1Stroke);

    Paint paint1Fill = Paint()..style = PaintingStyle.fill;
    paint1Fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path1, paint1Fill);

    Path path2 = Path();
    path2.moveTo(0, 0);
    path2.lineTo(size.width, size.height);
    path2.moveTo(size.width, 0);
    path2.lineTo(0, size.height);

    Paint paint2Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06666667;
    paint2Stroke.color = Color(0xffC8102E).withOpacity(1.0);
    canvas.drawPath(path2, paint2Stroke);

    Paint paint2Fill = Paint()..style = PaintingStyle.fill;
    paint2Fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path2, paint2Fill);

    Path path3 = Path();
    path3.moveTo(size.width * 0.5000000, 0);
    path3.lineTo(size.width * 0.5000000, size.height);
    path3.moveTo(0, size.height * 0.5000000);
    path3.lineTo(size.width, size.height * 0.5000000);

    Paint paint3Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1666667;
    paint3Stroke.color = Color(0xffffffff).withOpacity(1.0);
    canvas.drawPath(path3, paint3Stroke);

    Paint paint3Fill = Paint()..style = PaintingStyle.fill;
    paint3Fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path3, paint3Fill);

    Path path4 = Path();
    path4.moveTo(size.width * 0.5000000, 0);
    path4.lineTo(size.width * 0.5000000, size.height);
    path4.moveTo(0, size.height * 0.5000000);
    path4.lineTo(size.width, size.height * 0.5000000);

    Paint paint4Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1000000;
    paint4Stroke.color = Color(0xffC8102E).withOpacity(1.0);
    canvas.drawPath(path4, paint4Stroke);

    Paint paint4Fill = Paint()..style = PaintingStyle.fill;
    paint4Fill.color = Color(0xff000000).withOpacity(1.0);
    canvas.drawPath(path4, paint4Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
