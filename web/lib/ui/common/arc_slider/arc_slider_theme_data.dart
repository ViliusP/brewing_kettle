import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ArcSliderThemeData {
  /// The height of the [ArcSlider] track.
  final double? trackHeight;

  /// The color of the [ArcSlider] track between the [ArcSlider.min] position and the
  /// current thumb position.
  final Color? activeTrackColor;

  /// The color of the [Slider] track between the current thumb position and the
  /// [ArcSlider.max] position.
  final Color? inactiveTrackColor;

  /// The color of the [ArcSlider] track between the current thumb position and the
  /// [ArcSlider.secondaryTrackValue] position.
  final Color? secondaryActiveTrackColor;

  /// The color of the [ArcSlider] track between the [ArcSlider.min] position and the
  /// current thumb position when the [Slider] is disabled.
  final Color? disabledActiveTrackColor;

  /// The color of the [ArcSlider] track between the current thumb position and the
  /// [ArcSlider.secondaryTrackValue] position when the [ArcSlider] is disabled.
  final Color? disabledSecondaryActiveTrackColor;

  /// The color of the [ArcSlider] track between the current thumb position and the
  /// [ArcSlider.max] position when the [ArcSlider] is disabled.
  final Color? disabledInactiveTrackColor;

  /// The color of the track's tick marks that are drawn between the [ArcSlider.min]
  /// position and the current thumb position.
  final Color? activeTickMarkColor;

  /// The color of the track's tick marks that are drawn between the current
  /// thumb position and the [Slider.max] position.
  final Color? inactiveTickMarkColor;

  /// The color of the track's tick marks that are drawn between the [ArcSlider.min]
  /// position and the current thumb position when the [ArcSlider] is disabled.
  final Color? disabledActiveTickMarkColor;

  /// The color of the track's tick marks that are drawn between the current
  /// thumb position and the [ArcSlider.max] position when the [ArcSlider] is
  /// disabled.
  final Color? disabledInactiveTickMarkColor;

  /// The color given to the [thumbShape] to draw itself with.
  final Color? thumbColor;

  /// The color given to the [thumbShape] to draw itself with when the
  /// [ArcSlider] is disabled.
  final Color? disabledThumbColor;

  ArcSliderThemeData({
    this.trackHeight,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.secondaryActiveTrackColor,
    this.disabledActiveTrackColor,
    this.disabledSecondaryActiveTrackColor,
    this.disabledInactiveTrackColor,
    this.activeTickMarkColor,
    this.inactiveTickMarkColor,
    this.disabledActiveTickMarkColor,
    this.disabledInactiveTickMarkColor,
    this.thumbColor,
    this.disabledThumbColor,
  });
}

class ArcSliderPainterData implements ArcSliderThemeData {
  /// The height of the [ArcSlider] track.
  @override
  final double trackHeight;

  /// The color of the [ArcSlider] track between the [ArcSlider.min] position and the
  ///
  /// current thumb position.
  @override
  final Color activeTrackColor;

  /// The color of the [Slider] track between the current thumb position and the
  /// [ArcSlider.max] position.
  @override
  final Color inactiveTrackColor;

  /// The color of the [ArcSlider] track between the current thumb position and the
  /// [ArcSlider.secondaryTrackValue] position.
  @override
  final Color secondaryActiveTrackColor;

  /// The color of the [ArcSlider] track between the [ArcSlider.min] position and the
  /// current thumb position when the [Slider] is disabled.
  @override
  final Color disabledActiveTrackColor;

  /// The color of the [ArcSlider] track between the current thumb position and the
  /// [ArcSlider.secondaryTrackValue] position when the [ArcSlider] is disabled.
  @override
  final Color disabledSecondaryActiveTrackColor;

  /// The color of the [ArcSlider] track between the current thumb position and the
  /// [ArcSlider.max] position when the [ArcSlider] is disabled.
  @override
  final Color disabledInactiveTrackColor;

  /// The color of the track's tick marks that are drawn between the [ArcSlider.min]
  /// position and the current thumb position.
  @override
  final Color activeTickMarkColor;

  /// The color of the track's tick marks that are drawn between the current
  /// thumb position and the [Slider.max] position.
  @override
  final Color? inactiveTickMarkColor;

  /// The color of the track's tick marks that are drawn between the [ArcSlider.min]
  /// position and the current thumb position when the [ArcSlider] is disabled.
  @override
  final Color disabledActiveTickMarkColor;

  /// The color of the track's tick marks that are drawn between the current
  /// thumb position and the [ArcSlider.max] position when the [ArcSlider] is
  /// disabled.
  @override
  final Color disabledInactiveTickMarkColor;

  /// The color given to the [thumbShape] to draw itself with.
  @override
  final Color thumbColor;

  /// The color given to the [thumbShape] to draw itself with when the
  /// [ArcSlider] is disabled.
  @override
  final Color disabledThumbColor;

  ArcSliderPainterData({
    // primary track
    required this.trackHeight,
    required this.activeTrackColor,
    required this.inactiveTrackColor,
    required this.disabledInactiveTrackColor,
    // secondary track
    required this.secondaryActiveTrackColor,
    required this.disabledActiveTrackColor,
    required this.disabledSecondaryActiveTrackColor,
    // tick
    required this.activeTickMarkColor,
    required this.inactiveTickMarkColor,
    required this.disabledActiveTickMarkColor,
    required this.disabledInactiveTickMarkColor,
    // thumb
    required this.thumbColor,
    required this.disabledThumbColor,
  }) : super();

  factory ArcSliderPainterData.fromContext(BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;

    return ArcSliderPainterData(
      // primary track
      trackHeight: 2,
      activeTrackColor: scheme.primary,
      inactiveTrackColor: scheme.surfaceContainerHighest,
      disabledInactiveTrackColor: scheme.onSurface.withValues(alpha: 0.12),
      // secondary track
      secondaryActiveTrackColor: scheme.primary.withValues(alpha: 0.54),
      disabledActiveTrackColor: scheme.onSurface.withValues(alpha: 0.38),
      disabledSecondaryActiveTrackColor: scheme.onSurface.withValues(alpha: 0.12),
      // tick
      activeTickMarkColor: scheme.onPrimary.withValues(alpha: 0.38),
      inactiveTickMarkColor: scheme.onSurfaceVariant.withValues(alpha: 0.38),
      disabledActiveTickMarkColor: scheme.onSurface.withValues(alpha: 0.38),
      disabledInactiveTickMarkColor: scheme.onSurface.withValues(alpha: 0.38),
      // thumb
      thumbColor: scheme.primary,
      disabledThumbColor: Color.alphaBlend(
        scheme.onSurface.withValues(alpha: 0.38),
        scheme.surface,
      ),
    );
  }
}
