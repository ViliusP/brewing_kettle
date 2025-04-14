import 'package:flutter/material.dart';

/// A customizable and interactive slider widget for Flutter.
///
/// The `SliderContainer` is a stateful widget that allows users to adjust
/// a value by dragging or tapping within a container. It supports different
/// directions (up, down, left, right) and provides visual feedback.
///
/// Features:
/// - Supports drag and tap gestures to adjust the value.
/// - Directional layout: up, down, left, or right.
/// - Value is mapped as a percentage of a given range.
/// - Step-based value adjustment.
/// - Optional color fade effect based on value percentage.
/// - Hover effect for better user interaction feedback.
/// - Easily integrated into layouts, resizable and positionable.
/// - Customizable appearance via `SliderContainerDecorations`.
///
/// Use this widget when you need a slider that can fit a flexible UI layout
/// and offer enhanced interaction and styling options.
class SliderContainer extends StatefulWidget {
  final Widget child;
  final AxisDirection direction;
  final double value;
  final RangeValues range;
  final double step;
  final void Function(double)? onChanged;
  final SliderContainerDecorations decorations;

  const SliderContainer({
    super.key,
    required this.child,
    this.direction = AxisDirection.up,
    required this.value,
    required this.range,
    required this.onChanged,
    this.step = 1.0,
    this.decorations = const SliderContainerDecorations(),
  });

  @override
  State<SliderContainer> createState() => _SliderContainerState();
}

class _SliderContainerState extends State<SliderContainer> {
  bool _dragging = false;
  bool _hovered = false;

  /// Handles gesture input (tap or drag) and updates the slider value
  /// based on the touch position and slider orientation.
  void onGesture(Offset position, BoxConstraints boxConstraints) {
    double dy = position.dy;
    double dx = position.dx;
    double maxHeight = boxConstraints.maxHeight;
    double maxWidth = boxConstraints.maxWidth;

    // Convert touch position to percentage based on direction
    double percent = switch (widget.direction) {
      AxisDirection.up => (maxHeight - dy) / maxHeight,
      AxisDirection.down => dy / maxHeight,
      AxisDirection.right => dx / maxWidth,
      AxisDirection.left => (maxWidth - dx) / maxWidth,
    };

    // Calculate and clamp the new value using step size
    var newValue = (widget.range.end - widget.range.start) * percent;
    newValue = (newValue / widget.step).ceil() * widget.step;
    newValue = newValue.clamp(widget.range.start, widget.range.end);
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    var fillPercent = widget.value / (widget.range.end - widget.range.start);
    fillPercent = fillPercent.clamp(0, 100);

    Color color = colorScheme.primary;
    if (widget.decorations.withColorFade) {
      color = color.withAlpha((25 + 15 * fillPercent).toInt());
    }

    Color hoverColor = colorScheme.primary.withAlpha(10);

    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: switch (_dragging) {
            true => SystemMouseCursors.grabbing,
            false => SystemMouseCursors.grab,
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              if (!_dragging) setState(() => _dragging = true);
              onGesture(details.localPosition, constraints);
            },
            onTapUp: (_) => setState(() => _dragging = false),
            onTapCancel: () => setState(() => _dragging = false),
            onVerticalDragUpdate: (details) {
              if (!_dragging) setState(() => _dragging = true);
              onGesture(details.localPosition, constraints);
            },
            onVerticalDragStart: (details) {
              if (!_dragging) setState(() => _dragging = true);
              onGesture(details.localPosition, constraints);
            },
            onVerticalDragEnd: (_) => setState(() => _dragging = false),
            onVerticalDragCancel: () => setState(() => _dragging = false),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedContainer(
                    color: _hovered ? hoverColor : const Color.fromARGB(0, 255, 255, 255),
                    duration: Durations.long4,
                    curve: Curves.easeOutQuint,
                  ),
                ),
                Align(
                  alignment: switch (widget.direction) {
                    AxisDirection.up => Alignment.bottomCenter,
                    AxisDirection.down => Alignment.topCenter,
                    AxisDirection.right => Alignment.centerLeft,
                    AxisDirection.left => Alignment.centerRight,
                  },
                  child: AnimatedContainer(
                    height: switch (widget.direction) {
                      AxisDirection.up => constraints.maxHeight * fillPercent,
                      AxisDirection.down => constraints.maxHeight * fillPercent,
                      AxisDirection.right => null,
                      AxisDirection.left => null,
                    },
                    width: switch (widget.direction) {
                      AxisDirection.up => null,
                      AxisDirection.down => null,
                      AxisDirection.right => constraints.maxWidth * fillPercent,
                      AxisDirection.left => constraints.maxWidth * fillPercent,
                    },
                    color: color,
                    duration: Durations.medium1,
                    curve: Curves.fastEaseInToSlowEaseOut,
                  ),
                ),
                widget.child,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Visual customization options for [SliderContainer].
///
/// Currently supports enabling/disabling a color fade effect based on value.
class SliderContainerDecorations {
  const SliderContainerDecorations({this.withColorFade = true});

  final bool withColorFade;
}
