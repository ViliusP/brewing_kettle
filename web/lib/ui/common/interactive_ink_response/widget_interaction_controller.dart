import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

sealed class WidgetInteraction {
  const WidgetInteraction();
}

class WidgetPress extends WidgetInteraction {
  final Duration duration;
  final Offset? globalPosition;

  const WidgetPress({required this.duration, this.globalPosition});

  const WidgetPress.tap({this.duration = Duration.zero, this.globalPosition});

  const WidgetPress.long({this.duration = const Duration(milliseconds: 500), this.globalPosition});
}

class WidgetInteractionController extends ValueNotifier<Queue<WidgetInteraction>> {
  /// Creates a WidgetStatesController.
  WidgetInteractionController() : super(Queue());

  void interact(WidgetInteraction interaction) {
    value.add(interaction);
    notifyListeners();
  }
}
