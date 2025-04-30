import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

enum DragEventType { start, move, end, windowResize }

class DragEventDetails {
  final DragEventType type;
  final Offset offset;

  const DragEventDetails({required this.type, required this.offset});
}

/// A builder function that creates a widget for the draggable item.
/// The function receives the current context and a boolean indicating
/// whether the widget is currently being dragged.
/// The [bounded] parameter is true when the widget is being dragged,
/// and false when it is not.
typedef DraggableBuilder = Widget Function(BuildContext context, bool bounded);

/// A widget that can be dragged around the screen.
/// It can be [bounded] to the screen bounds or allowed to move freely.
/// The widget uses a [builder] function to create its content.
/// The [builder] function receives the current context and a boolean indicating
/// whether the widget is currently being dragged.
/// Example usage:
/// ```dart
/// Stack(
///   children: [
///     FloatingDraggable(
///       builder: (context, dragging) {
///         return Container(
///           width: 100,
///           height: 100,
///           color: dragging ? Colors.red : Colors.blue,
///           child: const Center(child: Text('Drag me')),
///         );
///       },
///     ),
///   ],
/// )
/// ```
class FloatingDraggable extends StatefulWidget {
  /// Whether the widget should be restricted to the screen bounds.
  ///
  /// If true, the widget will not be allowed to move outside the screen.
  /// If false, the widget can be dragged anywhere on the screen.
  /// Default is true.
  final bool bounded;

  /// Whether the widget should adjust its position when the window is resized.
  ///
  /// If true, the widget will reposition itself to remain within the visible
  /// bounds of the screen when the window is resized.
  /// If false, the widget will not adjust its position on window resize.
  /// Default is true.
  final bool adjustOnResize;

  /// A builder function that creates the draggable widget's content.
  ///
  /// The [builder] function is called with the current [BuildContext] and a
  /// boolean indicating whether the widget is currently being dragged.
  final DraggableBuilder builder;

  /// A callback function that is called when a drag event occurs.
  ///
  /// The [onDragEvent] function receives a [DragEventDetails] object
  /// containing information about the drag event.
  /// The type property indicates whether the event is a start, move, or end event.
  /// The offset property contains the current position of the drag event.
  /// This callback can be used to perform custom actions based on the drag event.
  final ValueChanged<DragEventDetails>? onDragEvent;

  /// The initial position of the widget.
  ///
  /// It can be used to set the initial position of the widget
  /// when it is first created.
  /// The default value is Offset.zero.
  final Offset initialPosition;

  const FloatingDraggable({
    super.key,
    required this.builder,
    this.bounded = true,
    this.adjustOnResize = true,
    this.onDragEvent,
    this.initialPosition = Offset.zero,
  });

  @override
  State<FloatingDraggable> createState() => _FloatingDraggableState();
}

class _FloatingDraggableState extends State<FloatingDraggable> with WindowListener {
  @override
  void initState() {
    super.initState();
    top = widget.initialPosition.dy;
    left = widget.initialPosition.dx;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setWidgetSize();
      moveChildToBounds();
      setState(() {});
    });

    windowManager.addListener(this);
  }

  @override
  void didUpdateWidget(covariant FloatingDraggable oldWidget) {
    if (oldWidget.builder != widget.builder) {
      checkWidgetSize = true;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void onWindowResize() {
    if (!widget.adjustOnResize || !widget.bounded) return;
    if (!mounted) return;

    if (!isChildInBounds()) {
      moveChildToBounds();
      widget.onDragEvent?.call(
        DragEventDetails(type: DragEventType.windowResize, offset: position),
      );
      setState(() {});
    }
  }

  double top = 0;
  double left = 0;
  Offset get position => Offset(left, top);

  bool dragging = false;
  Offset pointerOffset = Offset.zero;
  bool checkWidgetSize = true;
  Size widgetSize = Size.zero;

  static const defaultDraggingCursor = SystemMouseCursors.grabbing;
  static const defaultCursor = SystemMouseCursors.grab;

  /// Checks if the child widget is within the screen bounds.
  ///
  /// Returns true if the child widget is fully within the screen bounds,
  /// otherwise returns false.
  bool isChildInBounds() {
    final Size windowSize = MediaQuery.of(context).size;
    Rect windowRect = Rect.fromLTWH(0, 0, windowSize.width, windowSize.height);
    Rect childRect = Rect.fromLTWH(left, top, widgetSize.width, widgetSize.height);

    Rect intersection = windowRect.intersect(childRect);

    return intersection == childRect;
  }

  /// Moves the child widget to the nearest valid position within the screen bounds.
  ///
  /// If the widget is currently outside the screen bounds, it will be repositioned
  /// to the nearest valid position.
  /// If the widget is already within the screen bounds, no action is taken.
  void moveChildToBounds() {
    if (isChildInBounds()) {
      return;
    }
    final Size windowSize = MediaQuery.of(context).size;
    top = top.clamp(0.0, windowSize.height - widgetSize.height);
    left = left.clamp(0.0, windowSize.width - widgetSize.width);
  }

  void onLongPressStart(LongPressStartDetails details) {
    setWidgetSize();
    setState(() {
      dragging = true;
      pointerOffset = details.localPosition;
    });
    widget.onDragEvent?.call(DragEventDetails(type: DragEventType.start, offset: position));
  }

  void onLongPressEnd(LongPressEndDetails details) {
    setWidgetSize();
    setState(() {
      dragging = false;
      moveChildToBounds();
    });

    widget.onDragEvent?.call(DragEventDetails(type: DragEventType.end, offset: position));
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    setWidgetSize();
    setState(() {
      Offset offset = details.globalPosition - pointerOffset;
      top = offset.dy;
      left = offset.dx;
    });
    widget.onDragEvent?.call(DragEventDetails(type: DragEventType.move, offset: position));
  }

  void setWidgetSize() {
    if (checkWidgetSize) {
      final RenderBox? widgetBox = context.findRenderObject() as RenderBox?;
      if (widgetBox != null) {
        widgetSize = widgetBox.size;
        checkWidgetSize = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      top: top,
      left: left,
      duration: Durations.short1,
      curve: Curves.linearToEaseOut,
      child: MouseRegion(
        cursor: dragging ? defaultDraggingCursor : defaultCursor,
        child: GestureDetector(
          dragStartBehavior: DragStartBehavior.down,
          onLongPressStart: onLongPressStart,
          onLongPressEnd: onLongPressEnd,
          onLongPressMoveUpdate: onLongPressMoveUpdate,
          child: IgnorePointer(ignoring: dragging, child: widget.builder(context, dragging)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }
}
