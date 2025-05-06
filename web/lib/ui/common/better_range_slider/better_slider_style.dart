import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BetterSliderTrackStyles with Diagnosticable {
  final BetterSliderTrackStyle active;
  final BetterSliderTrackStyle inactive;

  const BetterSliderTrackStyles({
    this.active = const BetterSliderTrackStyle(),
    this.inactive = const BetterSliderTrackStyle(),
  });
}

class BetterSliderTrackStyle with Diagnosticable {
  /// Create a [BetterSliderTrackStyle].
  const BetterSliderTrackStyle({this.height, this.shape, this.color, this.mouseCursor});

  final WidgetStateProperty<double?>? height;

  final WidgetStateProperty<OutlinedBorder?>? shape;

  final WidgetStateProperty<Color?>? color;

  final WidgetStateProperty<MouseCursor?>? mouseCursor;
}

class BetterSliderHandleStyle with Diagnosticable {
  const BetterSliderHandleStyle({
    this.size,
    this.shape,
    this.color,
    this.padding,
    this.mouseCursor,
  });

  final WidgetStateProperty<Size?>? size;

  final WidgetStateProperty<OutlinedBorder?>? shape;

  final WidgetStateProperty<Color?>? color;

  final WidgetStateProperty<EdgeInsets?>? padding;

  final WidgetStateProperty<MouseCursor?>? mouseCursor;
}

class BetterSliderValueIndicatorStyle with Diagnosticable {
  const BetterSliderValueIndicatorStyle({
    this.textStyle,
    this.color,
    this.bottomSpace,
    this.shape,
    this.size,
  });

  final WidgetStateProperty<TextStyle?>? textStyle;

  final WidgetStateProperty<OutlinedBorder?>? shape;

  final WidgetStateProperty<Size?>? size;

  final WidgetStateProperty<Color?>? color;

  final WidgetStateProperty<double?>? bottomSpace;
}

class BetterSliderStyle with Diagnosticable {
  /// Create a [BetterSliderStyle].
  const BetterSliderStyle({
    this.tracks = const BetterSliderTrackStyles(),
    this.handle = const BetterSliderHandleStyle(),
    this.valueIndicator = const BetterSliderValueIndicatorStyle(),
  });

  final BetterSliderTrackStyles tracks;
  final BetterSliderHandleStyle handle;
  final BetterSliderValueIndicatorStyle valueIndicator;
}

class ExampleBetterSliderStyle with Diagnosticable {
  /// Create a [ButtonStyle].
  const ExampleBetterSliderStyle({
    this.mouseCursor,
    this.visualDensity,
    this.tapTargetSize,
    this.animationDuration,
    this.enableFeedback,
  });

  /// The cursor for a mouse pointer when it enters or is hovering over
  /// this button's [InkWell].
  final WidgetStateProperty<MouseCursor?>? mouseCursor;

  /// Defines how compact the button's layout will be.
  ///
  /// {@macro flutter.material.themedata.visualDensity}
  ///
  /// See also:
  ///
  ///  * [ThemeData.visualDensity], which specifies the [visualDensity] for all widgets
  ///    within a [Theme].
  final VisualDensity? visualDensity;

  /// Configures the minimum size of the area within which the button may be pressed.
  ///
  /// If the [tapTargetSize] is larger than [minimumSize], the button will include
  /// a transparent margin that responds to taps.
  ///
  /// Always defaults to [ThemeData.materialTapTargetSize].
  final MaterialTapTargetSize? tapTargetSize;

  /// Defines the duration of animated changes for [shape] and [elevation].
  ///
  /// Typically the component default value is [kThemeChangeDuration].
  final Duration? animationDuration;

  /// Whether detected gestures should provide acoustic and/or haptic feedback.
  ///
  /// For example, on Android a tap will produce a clicking sound and a
  /// long-press will produce a short vibration, when feedback is enabled.
  ///
  /// Typically the component default value is true.
  ///
  /// See also:
  ///
  ///  * [Feedback] for providing platform-specific feedback to certain actions.
  final bool? enableFeedback;

  /// Returns a copy of this ButtonStyle with the given fields replaced with
  /// the new values.
  ExampleBetterSliderStyle copyWith({
    WidgetStateProperty<TextStyle?>? textStyle,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? foregroundColor,
    WidgetStateProperty<Color?>? overlayColor,
    WidgetStateProperty<Color?>? shadowColor,
    WidgetStateProperty<Color?>? surfaceTintColor,
    WidgetStateProperty<double?>? elevation,
    WidgetStateProperty<EdgeInsetsGeometry?>? padding,
    WidgetStateProperty<Size?>? minimumSize,
    WidgetStateProperty<Size?>? fixedSize,
    WidgetStateProperty<Size?>? maximumSize,
    WidgetStateProperty<Color?>? iconColor,
    WidgetStateProperty<double?>? iconSize,
    IconAlignment? iconAlignment,
    WidgetStateProperty<BorderSide?>? side,
    WidgetStateProperty<OutlinedBorder?>? shape,
    WidgetStateProperty<MouseCursor?>? mouseCursor,
    VisualDensity? visualDensity,
    MaterialTapTargetSize? tapTargetSize,
    Duration? animationDuration,
    bool? enableFeedback,
    AlignmentGeometry? alignment,
    InteractiveInkFeatureFactory? splashFactory,
    ButtonLayerBuilder? backgroundBuilder,
    ButtonLayerBuilder? foregroundBuilder,
  }) {
    return ExampleBetterSliderStyle(
      mouseCursor: mouseCursor ?? this.mouseCursor,
      visualDensity: visualDensity ?? this.visualDensity,
      tapTargetSize: tapTargetSize ?? this.tapTargetSize,
      animationDuration: animationDuration ?? this.animationDuration,
      enableFeedback: enableFeedback ?? this.enableFeedback,
    );
  }

  /// Returns a copy of this ButtonStyle where the non-null fields in [style]
  /// have replaced the corresponding null fields in this ButtonStyle.
  ///
  /// In other words, [style] is used to fill in unspecified (null) fields
  /// this ButtonStyle.
  ExampleBetterSliderStyle merge(ExampleBetterSliderStyle? style) {
    if (style == null) {
      return this;
    }
    return copyWith(
      mouseCursor: mouseCursor ?? style.mouseCursor,
      visualDensity: visualDensity ?? style.visualDensity,
      tapTargetSize: tapTargetSize ?? style.tapTargetSize,
      animationDuration: animationDuration ?? style.animationDuration,
      enableFeedback: enableFeedback ?? style.enableFeedback,
    );
  }

  @override
  int get hashCode {
    final List<Object?> values = <Object?>[
      mouseCursor,
      visualDensity,
      tapTargetSize,
      animationDuration,
      enableFeedback,
    ];
    return Object.hashAll(values);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ExampleBetterSliderStyle &&
        other.mouseCursor == mouseCursor &&
        other.visualDensity == visualDensity &&
        other.tapTargetSize == tapTargetSize &&
        other.animationDuration == animationDuration &&
        other.enableFeedback == enableFeedback;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // properties.add(
    //   DiagnosticsProperty<WidgetStateProperty<TextStyle?>>(
    //     'textStyle',
    //     textStyle,
    //     defaultValue: null,
    //   ),
    // );

    properties.add(
      DiagnosticsProperty<WidgetStateProperty<MouseCursor?>>(
        'mouseCursor',
        mouseCursor,
        defaultValue: null,
      ),
    );
    properties.add(
      DiagnosticsProperty<VisualDensity>('visualDensity', visualDensity, defaultValue: null),
    );
    properties.add(
      EnumProperty<MaterialTapTargetSize>('tapTargetSize', tapTargetSize, defaultValue: null),
    );
    properties.add(
      DiagnosticsProperty<Duration>('animationDuration', animationDuration, defaultValue: null),
    );
    properties.add(DiagnosticsProperty<bool>('enableFeedback', enableFeedback, defaultValue: null));
  }

  /// Linearly interpolate between two [ButtonStyle]s.
  static ButtonStyle? lerp(ButtonStyle? a, ButtonStyle? b, double t) {
    if (identical(a, b)) {
      return a;
    }
    return ButtonStyle(
      textStyle: WidgetStateProperty.lerp<TextStyle?>(
        a?.textStyle,
        b?.textStyle,
        t,
        TextStyle.lerp,
      ),
      backgroundColor: WidgetStateProperty.lerp<Color?>(
        a?.backgroundColor,
        b?.backgroundColor,
        t,
        Color.lerp,
      ),
      foregroundColor: WidgetStateProperty.lerp<Color?>(
        a?.foregroundColor,
        b?.foregroundColor,
        t,
        Color.lerp,
      ),
      overlayColor: WidgetStateProperty.lerp<Color?>(
        a?.overlayColor,
        b?.overlayColor,
        t,
        Color.lerp,
      ),
      shadowColor: WidgetStateProperty.lerp<Color?>(a?.shadowColor, b?.shadowColor, t, Color.lerp),
      surfaceTintColor: WidgetStateProperty.lerp<Color?>(
        a?.surfaceTintColor,
        b?.surfaceTintColor,
        t,
        Color.lerp,
      ),
      elevation: WidgetStateProperty.lerp<double?>(a?.elevation, b?.elevation, t, lerpDouble),
      padding: WidgetStateProperty.lerp<EdgeInsetsGeometry?>(
        a?.padding,
        b?.padding,
        t,
        EdgeInsetsGeometry.lerp,
      ),
      minimumSize: WidgetStateProperty.lerp<Size?>(a?.minimumSize, b?.minimumSize, t, Size.lerp),
      fixedSize: WidgetStateProperty.lerp<Size?>(a?.fixedSize, b?.fixedSize, t, Size.lerp),
      maximumSize: WidgetStateProperty.lerp<Size?>(a?.maximumSize, b?.maximumSize, t, Size.lerp),
      iconColor: WidgetStateProperty.lerp<Color?>(a?.iconColor, b?.iconColor, t, Color.lerp),
      iconSize: WidgetStateProperty.lerp<double?>(a?.iconSize, b?.iconSize, t, lerpDouble),
      iconAlignment: t < 0.5 ? a?.iconAlignment : b?.iconAlignment,
      side: _lerpSides(a?.side, b?.side, t),
      shape: WidgetStateProperty.lerp<OutlinedBorder?>(a?.shape, b?.shape, t, OutlinedBorder.lerp),
      mouseCursor: t < 0.5 ? a?.mouseCursor : b?.mouseCursor,
      visualDensity: t < 0.5 ? a?.visualDensity : b?.visualDensity,
      tapTargetSize: t < 0.5 ? a?.tapTargetSize : b?.tapTargetSize,
      animationDuration: t < 0.5 ? a?.animationDuration : b?.animationDuration,
      enableFeedback: t < 0.5 ? a?.enableFeedback : b?.enableFeedback,
      alignment: AlignmentGeometry.lerp(a?.alignment, b?.alignment, t),
      splashFactory: t < 0.5 ? a?.splashFactory : b?.splashFactory,
      backgroundBuilder: t < 0.5 ? a?.backgroundBuilder : b?.backgroundBuilder,
      foregroundBuilder: t < 0.5 ? a?.foregroundBuilder : b?.foregroundBuilder,
    );
  }

  // Special case because BorderSide.lerp() doesn't support null arguments
  static WidgetStateProperty<BorderSide?>? _lerpSides(
    WidgetStateProperty<BorderSide?>? a,
    WidgetStateProperty<BorderSide?>? b,
    double t,
  ) {
    if (a == null && b == null) {
      return null;
    }
    return WidgetStateBorderSide.lerp(a, b, t);
  }
}
