import 'dart:ui';

extension ColorExtensions on Color {
  /// Darkens a color by a specified percentage.
  ///
  /// This method darkens the current color by the given [by] percentage.
  /// The [by] parameter should be a double between 0 and 100, where 100
  /// represents complete black.
  ///
  /// Example:
  /// ```dart
  /// Color myColor = Colors.blue;
  /// Color darkerColor = myColor.darken(by: 20); // Darken by 20%
  /// ```
  Color darken({required double by}) {
    assert(by >= 0 && by <= 100); // Ensure percentage is within valid range
    if (by == 0) return this;
    var f = 1 - by / 100; // Calculate the scaling factor

    // Create a new Color with adjusted RGB values.  Alpha remains the same.
    return Color.from(
      alpha: a, // Alpha channel (transparency) remains unchanged
      red: (r * f),
      green: (g * f),
      blue: (b * f),
    );
  }

  /// Lightens a color by a specified percentage.
  ///
  /// This method lightens the current color by the given [by] percentage.
  /// The [by] parameter should be a double between 0 and 100, where 100
  /// represents complete white.
  ///
  /// Example:
  /// ```dart
  /// Color myColor = Colors.blue;
  /// Color lighterColor = myColor.lighten(by: 20); // Lighten by 20%
  /// ```
  Color lighten({required double by}) {
    assert(by >= 0 && by <= 100); // Ensure percentage is within valid range
    if (by == 0) return this;

    var p = by / 100; // Calculate the percentage factor

    // Create a new Color with adjusted RGB values. Alpha remains the same.
    return Color.from(
      alpha: a, // Alpha channel (transparency) remains unchanged
      red: (r + ((1 - r) * p)),
      green: (g + ((1 - g) * p)),
      blue: (b + ((1 - b) * p)),
    );
  }
}
