import 'package:flutter/material.dart';

class DrawerRouteBarrierOptions {
  final bool enable;
  final bool closeOnClick;
  final Color color;

  const DrawerRouteBarrierOptions({
    this.enable = false,
    this.color = const Color.fromRGBO(0, 0, 0, 0.5),
    this.closeOnClick = true,
  });
}

///
class DrawerRouteOptions {
  final bool dragToDismiss;
  final DrawerRouteBarrierOptions barrier;

  const DrawerRouteOptions({
    this.dragToDismiss = false,
    this.barrier = const DrawerRouteBarrierOptions(),
  });
}

class DrawerMenu {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    RouteSettings? routeSettings,
    DrawerRouteOptions drawerOptions = const DrawerRouteOptions(),
  }) {
    return Navigator.of(context, rootNavigator: true).push<T?>(
      DrawerRoute<T?>(
        builder: builder,
        alignment: Alignment.centerRight,
        transitionDuration: Durations.short4,
        options: drawerOptions,
        settings: routeSettings,
      ),
    );
  }
}

class DrawerRoute<T> extends TransitionRoute<T> {
  final WidgetBuilder builder;
  final Alignment alignment;
  final DrawerRouteOptions options;
  final Curve animationCurve;

  DrawerRoute({
    required this.builder,
    this.alignment = Alignment.centerLeft, // Default to left side
    this.animationCurve = Curves.linear, // Default curve
    Duration transitionDuration = Durations.short4,
    this.options = const DrawerRouteOptions(),
    super.settings, // Pass RouteSettings if needed
  }) : _transitionDuration = transitionDuration;

  @override
  bool get opaque => false; // Needs to be false to see route below

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    return [
      OverlayEntry(
        builder: (BuildContext context) {
          final Offset begin;
          switch (alignment) {
            case Alignment.centerLeft:
            case Alignment.topLeft:
            case Alignment.bottomLeft:
              begin = const Offset(-1.0, 0.0); // Slide from left
              break;
            case Alignment.centerRight:
            case Alignment.topRight:
            case Alignment.bottomRight:
              begin = const Offset(1.0, 0.0); // Slide from right
              break;
            default:
              begin = const Offset(-1.0, 0.0); // Default to left
              break;
          }
          const Offset end = Offset.zero;

          final offsetTween = Tween<Offset>(begin: begin, end: end);

          final curvedAnimation = CurvedAnimation(
            parent: animation!, // Access the route's animation controller
            curve: animationCurve,
          );

          Widget content = Align(alignment: alignment, child: builder(context));

          if (options.dragToDismiss) {
            content = Dismissible(
              key: ValueKey("DrawerRoute<T>"),
              direction: DismissDirection.startToEnd,
              dismissThresholds: {DismissDirection.startToEnd: 0.1},
              behavior: HitTestBehavior.deferToChild,
              onDismissed: (direction) {
                if (navigator?.canPop() == true) {
                  navigator?.pop();
                }
              },
              child: content,
            );
          }

          content = SlideTransition(position: offsetTween.animate(curvedAnimation), child: content);

          if (options.barrier.enable) {
            content = Stack(
              children: [
                AnimatedModalBarrier(
                  onDismiss: options.barrier.closeOnClick ? null : () {},
                  color: ColorTween(
                    begin: const Color.fromRGBO(0, 0, 0, 0),
                    end: options.barrier.color,
                  ).animate(animation!),
                ),
                content,
              ],
            );
          }

          return content;
        },
      ),
    ];
  }

  @override
  bool get popGestureEnabled => true;

  final Duration _transitionDuration;

  @override
  Duration get transitionDuration => _transitionDuration;
}
