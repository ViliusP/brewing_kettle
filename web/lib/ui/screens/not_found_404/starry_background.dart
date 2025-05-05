import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// A class that defines the colors used in the starry background.
class StarryBackgroundColors {
  final Color background;
  final Color star;

  const StarryBackgroundColors()
    : background = const Color.fromARGB(255, 42, 34, 65),
      star = const Color.fromARGB(255, 255, 255, 255);

  const StarryBackgroundColors.custom({required this.background, required this.star});
}

/// Options for generating stars in the starry background.
class StarGenerationOptions {
  /// The number of stars to generate.
  final int count;

  /// The size interval for the stars.
  final ({double min, double max}) sizeInterval;

  /// The interval for the blinking effect of the stars.
  final ({Duration min, Duration max}) blinkingInterval;

  /// The minimum opacity of the stars.
  final ({double min, double max}) minOpacityInterval;

  /// The maximum opacity of the stars.
  final ({double min, double max}) maxOpacityInterval;

  /// The seed for random number generation.
  final int? seed;

  const StarGenerationOptions({
    required this.count,
    required this.sizeInterval,
    required this.blinkingInterval,
    required this.minOpacityInterval,
    required this.maxOpacityInterval,
    this.seed,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StarGenerationOptions &&
        other.count == count &&
        other.sizeInterval == sizeInterval &&
        other.blinkingInterval == blinkingInterval &&
        other.minOpacityInterval == minOpacityInterval &&
        other.maxOpacityInterval == maxOpacityInterval &&
        other.seed == seed;
  }

  @override
  int get hashCode {
    return count.hashCode ^
        sizeInterval.hashCode ^
        blinkingInterval.hashCode ^
        minOpacityInterval.hashCode ^
        maxOpacityInterval.hashCode ^
        seed.hashCode;
  }
}

/// A widget that displays a starry background with a gradient.
class StarryBackground extends StatefulWidget {
  final Widget child;

  final StarryBackgroundColors colors;
  final StarGenerationOptions generationOptions;

  const StarryBackground({
    super.key,
    required this.child,
    this.colors = const StarryBackgroundColors(),
    this.generationOptions = const StarGenerationOptions(
      count: 25,
      sizeInterval: (min: 2, max: 10),
      blinkingInterval: (min: Duration(seconds: 3), max: Duration(seconds: 6)),
      minOpacityInterval: (min: 0.05, max: 0.25),
      maxOpacityInterval: (min: 0.65, max: 0.95),
    ),
  });

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _GradientDecoration(colors: widget.colors),
        _StarryContainer(
          starColor: widget.colors.star,
          generationOptions: widget.generationOptions,
          blinkingCurve: Curves.easeInExpo,
        ),
        widget.child,
      ],
    );
  }
}

class _GradientDecoration extends StatelessWidget {
  final StarryBackgroundColors colors;

  const _GradientDecoration({this.colors = const StarryBackgroundColors()});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Color.fromARGB(255, 136, 56, 205), colors.background],
          stops: [0, 1],
          radius: 1.75,
          center: Alignment(.75, 2.9),
        ),
      ),
    );
  }
}

class _StarryContainer extends StatefulWidget {
  final StarGenerationOptions generationOptions;
  final Color starColor;
  final Curve blinkingCurve;

  const _StarryContainer({
    required this.starColor,
    required this.generationOptions,
    required this.blinkingCurve,
  });

  @override
  State<_StarryContainer> createState() => __StarryContainerState();
}

class __StarryContainerState extends State<_StarryContainer> {
  late Random random = Random(widget.generationOptions.seed ?? 80085);

  List<_GeneratedStarData> stars = [];
  Map<int, double> starScaling = {};
  static const ({double max, double min}) _hoverIncreaseRadiusInterval = (max: 25, min: 200);
  static const ({double max, double min}) _scaleInterval = (max: 3, min: 1);

  @override
  void didChangeDependencies() {
    random = Random(widget.generationOptions.seed ?? 80085);
    stars = List.generate(widget.generationOptions.count, generateStar);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant _StarryContainer oldWidget) {
    if (widget.generationOptions != oldWidget.generationOptions ||
        widget.starColor != oldWidget.starColor) {
      random = Random(widget.generationOptions.seed ?? 80085);
      stars = List.generate(widget.generationOptions.count, generateStar);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    random = Random(widget.generationOptions.seed ?? 80085);
    stars = List.generate(widget.generationOptions.count, generateStar);
    super.initState();
  }

  _GeneratedStarData generateStar(i) {
    double minOpacity =
        random.nextDouble() *
            (widget.generationOptions.minOpacityInterval.max -
                widget.generationOptions.minOpacityInterval.min) +
        widget.generationOptions.minOpacityInterval.min;

    double maxOpacity =
        random.nextDouble() *
            (widget.generationOptions.maxOpacityInterval.max -
                widget.generationOptions.maxOpacityInterval.min) +
        widget.generationOptions.maxOpacityInterval.min;

    return _GeneratedStarData(
      alignment: Alignment(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1),
      blinkDuration: Duration(
        milliseconds:
            random.nextInt(
              widget.generationOptions.blinkingInterval.max.inMilliseconds.toInt() -
                  widget.generationOptions.blinkingInterval.min.inMilliseconds.toInt(),
            ) +
            widget.generationOptions.blinkingInterval.min.inMilliseconds.toInt(),
      ),
      decoration: _StarDecoration(
        color: widget.starColor,
        size:
            random.nextDouble() *
                (widget.generationOptions.sizeInterval.max -
                    widget.generationOptions.sizeInterval.min) +
            widget.generationOptions.sizeInterval.min,

        opacity: (min: minOpacity, max: maxOpacity),
      ),
    );
  }

  double calculateRadius(double distance) {
    // Clamp the distance to our defined input range
    final clampedDistance = distance.clamp(
      _hoverIncreaseRadiusInterval.max,
      _hoverIncreaseRadiusInterval.min,
    );

    // Calculate interpolation parameter t [0, 1]
    final t =
        (clampedDistance - _hoverIncreaseRadiusInterval.max) /
        (_hoverIncreaseRadiusInterval.min - _hoverIncreaseRadiusInterval.max);

    // Perform linear interpolation between 2.5 and 1.0
    return _scaleInterval.max + (_scaleInterval.min - _scaleInterval.max) * t;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      onHover: (event) {
        Map<int, double> starScaling = {};
        Size containerSize = MediaQuery.of(context).size;

        for (var (index, star) in stars.indexed) {
          Offset starOffset = star.alignment.alongSize(containerSize);

          double distance = (event.localPosition - starOffset).distance;
          if (distance < _hoverIncreaseRadiusInterval.min) {
            starScaling[index] = calculateRadius(distance);
          }
        }
        if (starScaling != this.starScaling) {
          setState(() {
            this.starScaling = starScaling;
          });
        }
      },
      child: Stack(
        children:
            stars.mapIndexed((index, starData) {
              return Align(
                alignment: starData.alignment,
                child: _AnimatedStar(
                  decoration: starData.decoration,
                  blinkingCurve: widget.blinkingCurve,
                  blinkDuration: starData.blinkDuration,
                  scale: starScaling[index] ?? 1,
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _AnimatedStar extends StatefulWidget {
  final Curve blinkingCurve;
  final Duration blinkDuration;
  final double scale;
  final _StarDecoration decoration;

  const _AnimatedStar({
    this.scale = 1,
    required this.decoration,
    required this.blinkingCurve,
    required this.blinkDuration,
  });

  @override
  State<_AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<_AnimatedStar> with SingleTickerProviderStateMixin {
  late Animation colorTween;
  late AnimationController colorAnimationController;

  @override
  void initState() {
    super.initState();
    colorAnimationController = AnimationController(duration: widget.blinkDuration, vsync: this);

    colorTween =
        ColorTween(
            begin: widget.decoration.color.withAlpha(
              ((255 * widget.decoration.opacity.max).toInt()),
            ),
            end: widget.decoration.color.withAlpha(((255 * widget.decoration.opacity.min).toInt())),
          ).animate(CurvedAnimation(parent: colorAnimationController, curve: widget.blinkingCurve))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              colorAnimationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              colorAnimationController.forward();
            }
          })
          ..addListener(() {
            setState(() {});
          });
    colorAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.scale,
      curve: Curves.linear,
      duration: Durations.medium2,
      child: Container(
        width: widget.decoration.size,
        height: widget.decoration.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: colorTween.value),
      ),
    );
  }

  @override
  void dispose() {
    colorAnimationController.dispose();
    super.dispose();
  }
}

class _GeneratedStarData {
  final Alignment alignment;
  final _StarDecoration decoration;
  final Duration blinkDuration;

  const _GeneratedStarData({
    required this.alignment,
    required this.decoration,
    required this.blinkDuration,
  });
}

class _StarDecoration {
  final Color color;
  final double size;
  final ({double min, double max}) opacity;

  const _StarDecoration({required this.color, required this.size, required this.opacity});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _StarDecoration &&
        other.color == color &&
        other.size == size &&
        other.opacity == opacity;
  }

  @override
  int get hashCode {
    return color.hashCode ^ size.hashCode ^ opacity.hashCode;
  }
}
