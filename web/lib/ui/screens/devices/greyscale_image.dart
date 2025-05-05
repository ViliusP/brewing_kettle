import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';

class GrayscaleImage extends StatelessWidget {
  final Uint8List buffer; // Pre-buffered ARGB pixel data
  final int width; // Image width in pixels
  final int height; // Image height in pixels

  const GrayscaleImage({
    super.key,
    required this.buffer,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: createImageFromBuffer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          return CustomPaint(
            size: Size(width.toDouble(), height.toDouble()),
            painter: ImagePainter(snapshot.data!),
          );
        } else {
          return Text("Unknown error");
        }
      },
    );
  }

  Future<ui.Image> createImageFromBuffer() async {
    // Ensure the buffer size matches the expected dimensions
    if (buffer.length != width * height * 4) {
      throw ArgumentError(
        "Pixel buffer size (${buffer.length}) does not match the image dimensions ${width * height * 4}.",
      );
    }

    // Create an image from the ARGB buffer
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      buffer,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) => completer.complete(img),
    );
    return completer.future;
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
