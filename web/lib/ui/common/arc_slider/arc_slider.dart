// ignore_for_file: unused_field, unused_element

import 'dart:math';

import 'package:brew_kettle_dashboard/ui/common/arc_slider/arc_slider_painter.dart';
import 'package:brew_kettle_dashboard/ui/common/arc_slider/arc_slider_theme_data.dart';
import 'package:flutter/material.dart';

class ArcSlider extends StatefulWidget {
  final double value;
  final double? secondaryValue;

  /// The minimum value that the user can select.
  ///
  /// Must be less than the [max].
  final double min;

  /// The maximum value that the user can select.
  ///
  /// Must be greater than the [min].
  final double max;

  final ValueChanged<double>? onChanged;

  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;

  const ArcSlider({
    super.key,
    required this.min,
    required this.max,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    required this.value,
    this.secondaryValue,
  });

  @override
  State<ArcSlider> createState() => _ArcSliderState();
}

class _ArcSliderState extends State<ArcSlider> with SingleTickerProviderStateMixin {
  double _sliderValue = 0.0; // Value between 0 and 100

  final double startAngle = 3 * pi / 4;
  final double sweepAngle = 3 * pi / 2;
  final double arcWidth = 14;

  late AnimationController _handleAnimationController;
  late Animation<double> _handleAnimation;

  @override
  void initState() {
    super.initState();
    _handleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _handleAnimation = Tween<double>(begin: 10, end: 20).animate(_handleAnimationController);
  }

  ArcSliderPainterData _painterData(BuildContext context) {
    return ArcSliderPainterData.fromContext(context);
  }

  void _updateSliderValue(Offset localPosition, Rect arcRect) {
    final center = arcRect.center;
    final vector = localPosition - center;
    double angle = vector.direction;

    // Normalize the angle to be within [0, 2*pi]
    if (angle < 0) angle += 2 * pi;

    // Calculate adjusted angle relative to startAngle
    double adjustedAngle = (angle - startAngle) % (2 * pi);

    if (adjustedAngle <= sweepAngle) {
      // Inside the sweep angle
      final progress = adjustedAngle / sweepAngle;
      final newValue = widget.min + (widget.max - widget.min) * progress;
      widget.onChanged?.call(newValue);
    } else {
      // In the gap. Calculate distances correctly.

      // Calculate the angle to the END of the sweep
      double endAngle = (startAngle + sweepAngle) % (2 * pi);

      // Calculate the difference between the current angle and the start/end
      double diffToEnd = (angle - endAngle);
      double diffToStart = (angle - startAngle);

      // Take the shortest distance, considering wrap-around
      if (diffToEnd.abs() > pi) {
        diffToEnd = (2 * pi - diffToEnd.abs()) * (diffToEnd > 0 ? -1 : 1);
      }
      if (diffToStart.abs() > pi) {
        diffToStart = (2 * pi - diffToStart.abs()) * (diffToStart > 0 ? -1 : 1);
      }

      if (diffToEnd.abs() < diffToStart.abs()) {
        widget.onChanged?.call(widget.max);
      } else {
        widget.onChanged?.call(widget.min);
      }
    }
  }

  Offset _calculateHandlePosition(double value, Rect arcRect) {
    final center = arcRect.center;
    final radius = arcRect.width / 2;
    final progress = (value - widget.min) / (widget.max - widget.min);
    final angle = startAngle + progress * sweepAngle;
    final dx = center.dx + radius * cos(angle);
    final dy = center.dy + radius * sin(angle);
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    final ArcSliderPainterData painterData = _painterData(context);

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final arcRect = Rect.fromLTWH(
            arcWidth / 2,
            arcWidth / 2,
            constraints.maxWidth - arcWidth,
            constraints.maxWidth - arcWidth,
          );

          return GestureDetector(
            onPanUpdate: (details) {
              _updateSliderValue(details.localPosition, arcRect);
            },
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.square(constraints.maxWidth),
                  painter: ArcSliderPainter(
                    arcWidth: 10,
                    progress: 100,
                    startAngle: startAngle,
                    sweepAngle: sweepAngle,
                    color: painterData.inactiveTrackColor,
                  ),
                ),

                // CustomPaint(
                //   size: Size.square(constraints.maxWidth),
                //   painter: ArcSliderPainter(
                //     arcWidth: arcWidth,
                //     progress: widget.value,
                //     startAngle: startAngle,
                //     sweepAngle: sweepAngle,
                //     color: painterData.secondaryActiveTrackColor,
                //   ),
                // ),
                // if (widget.secondaryValue != null)
                //   CustomPaint(
                //     size: Size.square(constraints.maxWidth),
                //     painter: ArcSliderPainter(
                //       arcWidth: arcWidth,
                //       progress: widget.secondaryValue!,
                //       startAngle: startAngle,
                //       sweepAngle: sweepAngle,
                //       color: painterData.activeTrackColor,
                //     ),
                //   ),
                // AnimatedBuilder(
                //   animation: _handleAnimationController,
                //   builder: (context, child) {
                //     return CustomPaint(
                //       size: Size.square(constraints.maxWidth),
                //       painter: HandlePainter(
                //         handlePosition: _calculateHandlePosition(
                //           widget.value,
                //           arcRect,
                //         ),
                //         handleColor: painterData.thumbColor,
                //         handleSize: _handleAnimation.value,
                //         handleAngle: startAngle +
                //             (widget.value - widget.min) /
                //                 (widget.max - widget.min) *
                //                 sweepAngle,
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _handleAnimationController.dispose();
    super.dispose();
  }
}

class HandlePainter extends CustomPainter {
  final Offset handlePosition;
  final Color handleColor;
  final double handleSize;
  final double handleAngle;

  HandlePainter({
    required this.handlePosition,
    required this.handleColor,
    required this.handleSize,
    required this.handleAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = handleColor
          ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(handlePosition.dx, handlePosition.dy);
    canvas.rotate(handleAngle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          // this is height
          width: handleSize * 3,
          // this is width
          height: handleSize / 2.5,
        ),
        Radius.circular(4),
      ),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
