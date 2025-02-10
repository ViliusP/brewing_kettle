import 'package:flutter/material.dart';

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

  void onGesture(Offset position, BoxConstraints boxConstraints) {
    double dy = position.dy;
    double dx = position.dx;
    double maxHeight = boxConstraints.maxHeight;
    double maxWidth = boxConstraints.maxWidth;

    double percent = switch (widget.direction) {
      AxisDirection.up => (maxHeight - dy) / maxHeight,
      AxisDirection.down => dy / maxHeight,
      AxisDirection.right => dx / maxWidth,
      AxisDirection.left => (maxWidth - dx) / maxWidth,
    };

    var newValue = (widget.range.end - widget.range.start) * percent;
    newValue = (newValue / widget.step).ceil() * widget.step;
    newValue = newValue.clamp(widget.range.start, widget.range.end);
    widget.onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final fillPercent = widget.value / (widget.range.end - widget.range.start);

    Color color = colorScheme.primary;
    if (widget.decorations.withColorFade) {
      color = color.withAlpha((25 + 15 * fillPercent).toInt());
    }

    return LayoutBuilder(builder: (context, constraints) {
      return MouseRegion(
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
          onTapUp: (details) => setState(() => _dragging = false),
          onTapCancel: () => setState(() => _dragging = false),
          onVerticalDragUpdate: (details) {
            if (!_dragging) setState(() => _dragging = true);
            onGesture(details.localPosition, constraints);
          },
          onVerticalDragStart: (details) {
            if (!_dragging) setState(() => _dragging = true);
            onGesture(details.localPosition, constraints);
          },
          onVerticalDragEnd: (details) => setState(() => _dragging = false),
          onVerticalDragCancel: () => setState(() => _dragging = false),
          child: Stack(
            children: [
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
    });
  }
}

class SliderContainerDecorations {
  const SliderContainerDecorations({
    this.withColorFade = true,
  });

  final bool withColorFade;
}
