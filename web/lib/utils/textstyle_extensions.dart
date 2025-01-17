import 'package:flutter/widgets.dart';

extension TextstyleExtensions on TextStyle {
  TextStyle changeWeight(FontWeight value) {
    List<FontVariation> currentVariations = List.from(fontVariations ?? []);
    if (currentVariations.isNotEmpty == true) {
      fontVariations?.removeWhere(((v) => v.axis == "wght"));
    }
    currentVariations.add(FontVariation.weight(value.value.toDouble()));
    return copyWith(fontVariations: currentVariations);
  }
}
