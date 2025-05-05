import 'package:flutter/gestures.dart';

class MiddleMousePanGestureRecognizer extends PanGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    if (event.kind == PointerDeviceKind.mouse && event.buttons == kMiddleMouseButton) {
      super.addAllowedPointer(event);
    }
  }

  @override
  bool isPointerAllowed(PointerEvent event) {
    return event.buttons == 4;
  }
}
