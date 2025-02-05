import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedIdleCircles extends StatefulWidget {
  final int count;
  final double radius;
  final Color? color;

  const AnimatedIdleCircles({
    super.key,
    this.radius = 20,
    this.color,
    this.count = 5,
  });

  @override
  State<AnimatedIdleCircles> createState() => _AnimatedIdleCirclesState();
}

class _AnimatedIdleCirclesState extends State<AnimatedIdleCircles> {
  final Random _random = Random(5336);
  final List<double> _ranges = [];
  final List<VerticalDirection> _directions = [];
  final List<Duration> _durations = [];

  @override
  void initState() {
    for (int _ in List.generate(widget.count, (i) => i)) {
      _ranges.add(
        widget.radius / 2 + (_random.nextDouble() * widget.radius * 3),
      );
      _durations.add(Duration(milliseconds: 2000 + _random.nextInt(3000)));
      _directions.add(
        _random.nextBool() ? VerticalDirection.up : VerticalDirection.down,
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        for (int i in List.generate(widget.count, (i) => i)) {
          _directions[i] = switch (_directions[i]) {
            VerticalDirection.up => VerticalDirection.down,
            VerticalDirection.down => VerticalDirection.up
          };
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ??
        Theme.of(context).colorScheme.primary.withAlpha(255 ~/ 1.5);

    final double spacing = widget.radius / 4;
    double width = (widget.radius * widget.count);
    width += (widget.count - 1) * spacing;

    return LayoutBuilder(builder: (context, constraints) {
      double verticalCenter = (constraints.maxHeight - widget.radius) / 2;
      double horizontalCenter = (constraints.maxWidth - width) / 2;
      return Stack(
        fit: StackFit.expand,
        children: List.generate(widget.count, (index) {
          double left = horizontalCenter;
          if (index != 0) left += (widget.radius + spacing) * index;

          double top = verticalCenter;
          top += switch (_directions[index]) {
            VerticalDirection.up => -_ranges[index] / 2,
            VerticalDirection.down => _ranges[index] / 2
          };

          return AnimatedPositioned(
            duration: _durations[index],
            top: top,
            left: left,
            curve: Curves.elasticInOut,
            onEnd: () {
              setState(() {
                _directions[index] = switch (_directions[index]) {
                  VerticalDirection.up => VerticalDirection.down,
                  VerticalDirection.down => VerticalDirection.up
                };
                _ranges[index] = widget.radius / 2 +
                    (_random.nextDouble() * widget.radius * 3);
                _durations[index] = Duration(
                  milliseconds: 1500 + _random.nextInt(3000),
                );
              });
            },
            child: Container(
              width: widget.radius,
              height: widget.radius,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      );
    });
  }
}
