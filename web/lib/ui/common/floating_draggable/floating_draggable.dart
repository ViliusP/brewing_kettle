import 'package:flutter/material.dart';

typedef DraggableBuilder = Widget Function(BuildContext context, bool draggable);

class FloatingDraggable extends StatefulWidget {
  /// Whether the widget should be restricted to the screen bounds.
  ///
  /// If true, the widget will not be allowed to move outside the screen.
  /// If false, the widget can be dragged anywhere on the screen.
  /// Default is true.
  final bool restricted;
  final DraggableBuilder builder;

  const FloatingDraggable({super.key, required this.builder, this.restricted = true});

  @override
  State<FloatingDraggable> createState() => _FloatingDraggableState();
}

class _FloatingDraggableState extends State<FloatingDraggable> {
  double top = 0;
  double left = 0;
  bool dragging = false;
  Offset pointerOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: top,
      left: left,
      duration: Durations.short1,
      curve: Curves.linearToEaseOut,
      child: GestureDetector(
        onLongPressStart: (details) {
          setState(() {
            dragging = true;
          });
          pointerOffset = details.localPosition;
        },
        onLongPressEnd: (_) {
          setState(() {
            dragging = false;
            if (top < 0 && widget.restricted) {
              top = 0;
            }
            if (left < 0 && widget.restricted) {
              left = 0;
            }
          });
        },
        onLongPressMoveUpdate: (details) {
          setState(() {
            Offset offset = details.globalPosition - pointerOffset;
            top = offset.dy;
            left = offset.dx;
          });
        },
        child: widget.builder(context, dragging),
      ),
    );
  }
}
