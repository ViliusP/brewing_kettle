import 'package:flutter/material.dart';

class SliderContainer extends StatelessWidget {
  final Widget child;
  final AxisDirection direction;
  final double value;
  final RangeValues range;
  final double step;
  final void Function(double)? onChanged;

  const SliderContainer({
    super.key,
    required this.child,
    this.direction = AxisDirection.up,
    required this.value,
    required this.range,
    required this.onChanged,
    this.step = 1.0,
  });

  void onGesture(Offset position, BoxConstraints boxConstraints) {
    double dy = position.dy;
    double dx = position.dx;
    double maxHeight = boxConstraints.maxHeight;
    double maxWidth = boxConstraints.maxWidth;

    double percent = switch (direction) {
      AxisDirection.up => (maxHeight - dy) / maxHeight,
      AxisDirection.down => dy / maxHeight,
      AxisDirection.right => dx / maxWidth,
      AxisDirection.left => (maxWidth - dx) / maxWidth,
    };

    var newValue = (range.end - range.start) * percent;
    newValue = (newValue / step).ceil() * step;
    newValue = newValue.clamp(range.start, range.end);
    onChanged?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    var fillPercent = value / (range.end - range.start);

    // Slider()
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => onGesture(details.localPosition, constraints),
        onVerticalDragUpdate: (details) => onGesture(
          details.localPosition,
          constraints,
        ),
        onVerticalDragStart: (details) => onGesture(
          details.localPosition,
          constraints,
        ),
        child: Stack(
          children: [
            Align(
              alignment: switch (direction) {
                AxisDirection.up => Alignment.bottomCenter,
                AxisDirection.down => Alignment.topCenter,
                AxisDirection.right => Alignment.centerLeft,
                AxisDirection.left => Alignment.centerRight,
              },
              child: AnimatedContainer(
                height: switch (direction) {
                  AxisDirection.up => constraints.maxHeight * fillPercent,
                  AxisDirection.down => constraints.maxHeight * fillPercent,
                  AxisDirection.right => null,
                  AxisDirection.left => null,
                },
                width: switch (direction) {
                  AxisDirection.up => null,
                  AxisDirection.down => null,
                  AxisDirection.right => constraints.maxWidth * fillPercent,
                  AxisDirection.left => constraints.maxWidth * fillPercent,
                },
                color: Color.fromRGBO(0, 0, 0, 0.1),
                duration: Durations.medium1,
                curve: Curves.fastEaseInToSlowEaseOut,
              ),
            ),
            child,
          ],
        ),
      );
    });
  }
}
