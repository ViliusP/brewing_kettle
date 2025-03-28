import 'dart:typed_data';

class PixelFormatConverter {
  static Uint8List rgb888ToRgba8888(Uint8List data, int width, int height) {
    if (data.length != width * height * 3) {
      throw ArgumentError('Invalid rgbData length');
    }

    final rgbaData = Uint8List(width * height * 4);

    for (int i = 0; i < width * height; i++) {
      int rgbIndex = i * 3;
      int rgbaIndex = i * 4;

      rgbaData[rgbaIndex] = data[rgbIndex]; // Red
      rgbaData[rgbaIndex + 1] = data[rgbIndex + 1]; // Green
      rgbaData[rgbaIndex + 2] = data[rgbIndex + 2]; // Blue
      rgbaData[rgbaIndex + 3] = 255; // Alpha (fully opaque)
    }

    return rgbaData;
  }
}

extension PixelExtensions on Uint8List {
  Uint8List rgb888ToRgba8888(int width, int height) {
    return PixelFormatConverter.rgb888ToRgba8888(this, width, height);
  }
}
