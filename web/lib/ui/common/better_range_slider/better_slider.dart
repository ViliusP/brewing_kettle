import 'dart:ui';

import 'package:brew_kettle_dashboard/ui/common/better_range_slider/better_slider_style.dart';
import 'package:brew_kettle_dashboard/ui/common/better_range_slider/range.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _AdjustSliderIntent extends Intent {
  const _AdjustSliderIntent({required this.direction});

  const _AdjustSliderIntent.right() : direction = AxisDirection.right;

  const _AdjustSliderIntent.left() : direction = AxisDirection.left;

  // ignore: unused_element
  const _AdjustSliderIntent.up() : direction = AxisDirection.up;

  // ignore: unused_element
  const _AdjustSliderIntent.down() : direction = AxisDirection.down;

  final AxisDirection direction;
}

class BetterSlider extends StatefulWidget {
  /// The currently selected value for this slider.
  ///
  /// The slider's thumb is drawn at a position that corresponds to this value.
  final double value;

  /// Called during a drag when the user is selecting a new value for the slider
  /// by dragging.
  ///
  /// The slider passes the new value to the callback but does not actually
  /// change state until the parent widget rebuilds the slider with the new
  /// value.
  ///
  /// If null, the slider will be displayed as disabled.
  ///
  /// The callback provided to onChanged should update the state of the parent
  /// [StatefulWidget] using the [State.setState] method, so that the parent
  /// gets rebuilt; for example:
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// Slider<double>(
  ///   value: _duelCommandment.toDouble(),
  ///   min: 1.0,
  ///   max: 10.0,
  ///   divisions: 10,
  ///   label: '$_duelCommandment',
  ///   onChanged: (double newValue) {
  ///     setState(() {
  ///       _duelCommandment = newValue.round();
  ///     });
  ///   },
  /// )
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [onChangeStart] for a callback that is called when the user starts
  ///    changing the value.
  ///  * [onChangeEnd] for a callback that is called when the user stops
  ///    changing the value.
  final ValueChanged<double>? onChanged;

  final NumericalRange<double> limits;

  const BetterSlider({
    super.key,
    required this.onChanged,
    required this.value,
    required this.limits,
  });

  @override
  State<BetterSlider> createState() => _BetterRangeSliderState();
}

class _BetterRangeSliderState extends State<BetterSlider> {
  final GlobalKey sliderKey = GlobalKey(debugLabel: "slider_key");
  RenderBox? sliderRenderBox;

  WidgetStatesController? internalStatesController;

  WidgetStatesController get statesController => internalStatesController!;

  OverlayEntry? overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void handleStatesControllerChange() {
    // Force a rebuild to resolve MaterialStateProperty properties
    setState(() {});
  }

  void initStatesController() {
    internalStatesController = WidgetStatesController();
    if (widget.onChanged == null) {
      internalStatesController?.update(WidgetState.disabled, true);
    }
    statesController.addListener(handleStatesControllerChange);
  }

  void setSliderRenderBox() {
    sliderRenderBox = sliderKey.currentContext?.findRenderObject() as RenderBox?;
  }

  @override
  void initState() {
    super.initState();
    initStatesController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setSliderRenderBox();
      }
    });
  }

  @override
  void didUpdateWidget(BetterSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.statesController != oldWidget.statesController) {
    //   oldWidget.statesController?.removeListener(handleStatesControllerChange);
    //   if (widget.statesController != null) {
    //     internalStatesController?.dispose();
    //     internalStatesController = null;
    //   }
    //   initStatesController();
    // }
    if (widget.onChanged != oldWidget.onChanged) {
      statesController.update(WidgetState.disabled, widget.onChanged == null);
    }
  }

  late final Map<Type, Action<Intent>> _actionMap = <Type, Action<Intent>>{
    _AdjustSliderIntent: CallbackAction<_AdjustSliderIntent>(onInvoke: _handleArrowAction),
  };

  final Map<ShortcutActivator, Intent> _shortcutMap = const <ShortcutActivator, Intent>{
    SingleActivator(LogicalKeyboardKey.arrowLeft): _AdjustSliderIntent.left(),
    SingleActivator(LogicalKeyboardKey.arrowRight): _AdjustSliderIntent.right(),
  };

  void increaseAction() {
    if (widget.onChanged != null) {
      var increase = widget.limits.clamp(widget.value + 1);
      widget.onChanged!(increase);
    }
    // if (isInteractive) {
    //   onChangeStart!(currentValue);
    //   final double increase = increaseValue();
    //   onChanged!(increase);
    //   onChangeEnd!(increase);
    //   if (!_state.mounted) {
    //     return;
    //   }
    //   _state.showValueIndicator();
    // }
  }

  void decreaseAction() {
    if (widget.onChanged != null) {
      var decrease = widget.limits.clamp(widget.value - 1);
      widget.onChanged!(decrease);
    }
    // if (isInteractive) {
    //   onChangeStart!(currentValue);
    //   final double decrease = decreaseValue();
    //   onChanged!(decrease);
    //   onChangeEnd!(decrease);
    //   if (!_state.mounted) {
    //     return;
    //   }
    //   _state.showValueIndicator();
    // }
  }

  void showValueIndicator() {
    if (overlayEntry == null) {
      overlayEntry = OverlayEntry(
        builder: (BuildContext context) {
          final ColorScheme colorScheme = ColorScheme.of(context);
          final BetterSliderStyle themeStyle = styleFromColorScheme(colorScheme);
          final BetterSliderStyle defaultStyle = defaultSliderStyle();

          T? effectiveValue<T>(T? Function(BetterSliderStyle? style) getProperty) {
            final T? themeValue = getProperty(themeStyle);
            final T? defaultValue = getProperty(defaultStyle);
            return themeValue ?? defaultValue;
          }

          T? resolve<T>(WidgetStateProperty<T>? Function(BetterSliderStyle? style) getProperty) {
            return effectiveValue((BetterSliderStyle? style) {
              return getProperty(style)?.resolve(statesController.value);
            });
          }

          Size? valueIndicatorSize = resolve<Size?>(
            (BetterSliderStyle? style) => style?.valueIndicator.size,
          );

          return Positioned(
            width: valueIndicatorSize?.width,
            height: valueIndicatorSize?.height,
            child: CompositedTransformFollower(
              targetAnchor: Alignment.topCenter,
              followerAnchor: Alignment.bottomCenter,
              link: _layerLink,
              child: _SliderValueIndicator(
                state: this,
                bottomSpacing: resolve<double?>(
                  (BetterSliderStyle? style) => style?.valueIndicator.bottomSpace,
                ),
                textStyle: resolve<TextStyle?>(
                  (BetterSliderStyle? style) => style?.valueIndicator.textStyle,
                ),
                size: valueIndicatorSize,
                color: resolve<Color?>((BetterSliderStyle? style) => style?.valueIndicator.color),
                shape: resolve<OutlinedBorder?>(
                  (BetterSliderStyle? style) => style?.valueIndicator.shape,
                ),
              ),
            ),
          );
        },
      );
      Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
    }
  }

  double calcNewValue(double x, double width) {
    double clampedX = clampDouble(x, 0, width);
    return lerpDouble(widget.limits.min, widget.limits.max, clampedX / width) ?? widget.value;
  }

  void handleOnPanDown(DragDownDetails details) {
    setSliderRenderBox();
    showValueIndicator();
    statesController.update(WidgetState.pressed, true);
  }

  void handleOnPanUpdate(DragUpdateDetails details) {
    statesController.update(WidgetState.dragged, true);
    if (sliderRenderBox != null) {
      Offset? offset = sliderRenderBox?.globalToLocal(details.globalPosition);
      if (offset != null && widget.onChanged != null) {
        var newValue = calcNewValue(offset.dx, sliderRenderBox!.size.width);
        if (newValue != widget.value) {
          widget.onChanged!(newValue);
          overlayEntry?.markNeedsBuild();
        }
      }
    }
  }

  void handleOnPanCancel() {
    statesController.update(WidgetState.pressed, false);
    statesController.update(WidgetState.dragged, false);
    removeValueIndicator();
  }

  void handleOnPanEnd(DragEndDetails details) {
    statesController.update(WidgetState.pressed, false);
    statesController.update(WidgetState.dragged, false);
    removeValueIndicator();
  }

  void _handleArrowAction(Intent intent) {
    final TextDirection directionality = Directionality.of(context);

    if (intent is! _AdjustSliderIntent) return;
    bool increase = switch ((intent.direction, directionality)) {
      (AxisDirection.up, _) => true,
      (AxisDirection.down, _) => true,
      (AxisDirection.right, TextDirection.ltr) => true,
      (AxisDirection.right, TextDirection.rtl) => false,
      (AxisDirection.left, TextDirection.ltr) => false,
      (AxisDirection.left, TextDirection.rtl) => true,
    };
    return increase ? increaseAction() : decreaseAction();
  }

  void _handleFocusHighlight(bool value) {
    statesController.update(WidgetState.focused, value);
  }

  void removeValueIndicator() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }

  @override
  void dispose() {
    statesController.removeListener(handleStatesControllerChange);
    internalStatesController?.dispose();

    removeValueIndicator();
    super.dispose();
  }

  BetterSliderStyle styleFromColorScheme(ColorScheme colorScheme) {
    return BetterSliderStyle(
      handle: BetterSliderHandleStyle(
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
        ),
        size: WidgetStateProperty<Size?>.fromMap(<WidgetStatesConstraint, Size>{
          WidgetState.pressed: Size(2, 44),
          WidgetState.dragged: Size(2, 44),
          WidgetState.focused: Size(2, 44),
          WidgetState.any: Size(4, 44),
        }),
        padding: WidgetStatePropertyAll<EdgeInsets?>(EdgeInsets.symmetric(horizontal: 6)),
        color: WidgetStatePropertyAll<Color?>(colorScheme.primary),
        mouseCursor: WidgetStateProperty<MouseCursor>.fromMap(<WidgetStatesConstraint, MouseCursor>{
          WidgetState.pressed: SystemMouseCursors.grabbing,
          WidgetState.dragged: SystemMouseCursors.grabbing,
          WidgetState.hovered: SystemMouseCursors.grab,
          WidgetState.any: MouseCursor.defer,
        }),
      ),
      valueIndicator: BetterSliderValueIndicatorStyle(
        shape: WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder()),
        size: WidgetStatePropertyAll<Size>(Size(48, 44)),
        textStyle: WidgetStatePropertyAll<TextStyle?>(
          TextTheme.of(context).labelLarge?.copyWith(
            fontWeight: TextTheme.of(context).bodyLarge?.fontWeight,
            letterSpacing: TextTheme.of(context).bodyLarge?.letterSpacing,
            color: colorScheme.onInverseSurface,
          ),
        ),
        color: WidgetStatePropertyAll<Color?>(colorScheme.inverseSurface),
        bottomSpace: WidgetStatePropertyAll<double>(12),
      ),

      tracks: BetterSliderTrackStyles(
        active: BetterSliderTrackStyle(
          height: WidgetStatePropertyAll<double>(16),
          color: WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color>{
            WidgetState.disabled: colorScheme.onSurface.withAlpha(97),
            WidgetState.any: colorScheme.primary,
          }),
          mouseCursor: WidgetStateProperty<MouseCursor>.fromMap(
            <WidgetStatesConstraint, MouseCursor>{
              WidgetState.hovered: SystemMouseCursors.click,
              WidgetState.any: MouseCursor.defer,
            },
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                topRight: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ),
        inactive: BetterSliderTrackStyle(
          height: WidgetStatePropertyAll<double>(16),
          color: WidgetStateProperty<Color?>.fromMap(<WidgetStatesConstraint, Color>{
            WidgetState.disabled: colorScheme.onSurface.withAlpha(31),
            WidgetState.any: colorScheme.secondaryContainer,
          }),
          mouseCursor: WidgetStateProperty<MouseCursor>.fromMap(
            <WidgetStatesConstraint, MouseCursor>{
              WidgetState.hovered: SystemMouseCursors.click,
              WidgetState.any: MouseCursor.defer,
            },
          ),
          shape: WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BetterSliderStyle defaultSliderStyle() {
    return BetterSliderStyle(
      tracks: BetterSliderTrackStyles(
        active: BetterSliderTrackStyle(height: WidgetStatePropertyAll<double>(16)),
        inactive: BetterSliderTrackStyle(height: WidgetStatePropertyAll<double>(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.of(context);
    final BetterSliderStyle themeStyle = styleFromColorScheme(colorScheme);
    final BetterSliderStyle defaultStyle = defaultSliderStyle();

    T? effectiveValue<T>(T? Function(BetterSliderStyle? style) getProperty) {
      final T? themeValue = getProperty(themeStyle);
      final T? defaultValue = getProperty(defaultStyle);
      return themeValue ?? defaultValue;
    }

    T? resolve<T>(WidgetStateProperty<T>? Function(BetterSliderStyle? style) getProperty) {
      return effectiveValue((BetterSliderStyle? style) {
        return getProperty(style)?.resolve(statesController.value);
      });
    }

    // final ButtonStyleButton button = OutlinedButton(onPressed: () {}, child: Text(""));

    const int resolution = 10000;
    int activeFlexValue = (widget.limits.t(widget.value) * resolution).truncate();
    int inActiveFlexValue = resolution - activeFlexValue;

    return Semantics(
      container: true,
      slider: true,
      child: Row(
        key: sliderKey,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: activeFlexValue,
            child: MouseRegion(
              cursor:
                  widget.onChanged != null
                      ? (effectiveValue(
                            (BetterSliderStyle? style) => style?.tracks.active.mouseCursor,
                          )?.resolve({WidgetState.hovered}) ??
                          MouseCursor.defer)
                      : MouseCursor.defer,
              child: _SliderTrack(
                height: resolve<double?>((BetterSliderStyle? style) => style?.tracks.active.height),
                color: resolve<Color?>((BetterSliderStyle? style) => style?.tracks.active.color),
                shape: resolve<OutlinedBorder?>(
                  (BetterSliderStyle? style) => style?.tracks.active.shape,
                ),
              ),
            ),
          ),
          GestureDetector(
            onPanDown: handleOnPanDown,
            onPanUpdate: handleOnPanUpdate,
            onPanCancel: handleOnPanCancel,
            onPanEnd: handleOnPanEnd,
            child: MouseRegion(
              // cursor:
              //     widget.onChanged != null
              //         ? (effectiveValue(
              //               (BetterSliderStyle? style) => style?.handle.mouseCursor,
              //             )?.resolve({WidgetState.hovered}) ??
              //             MouseCursor.defer)
              //         : MouseCursor.defer,
              child: FocusableActionDetector(
                actions: _actionMap,
                shortcuts: _shortcutMap,
                onShowFocusHighlight: _handleFocusHighlight,
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: _SliderHandle(
                    padding: resolve<EdgeInsets?>(
                      (BetterSliderStyle? style) => style?.handle.padding,
                    ),
                    shape: resolve<OutlinedBorder?>(
                      (BetterSliderStyle? style) => style?.handle.shape,
                    ),
                    size: resolve<Size?>((BetterSliderStyle? style) => style?.handle.size),
                    color: resolve<Color?>(
                      (BetterSliderStyle? style) => style?.tracks.active.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: inActiveFlexValue,
            child: MouseRegion(
              cursor:
                  widget.onChanged != null
                      ? (effectiveValue(
                            (BetterSliderStyle? style) => style?.tracks.inactive.mouseCursor,
                          )?.resolve({WidgetState.hovered}) ??
                          MouseCursor.defer)
                      : MouseCursor.defer,
              child: _SliderTrack(
                height: resolve<double?>(
                  (BetterSliderStyle? style) => style?.tracks.inactive.height,
                ),
                color: resolve<Color?>((BetterSliderStyle? style) => style?.tracks.inactive.color),
                shape: resolve<OutlinedBorder?>(
                  (BetterSliderStyle? style) => style?.tracks.inactive.shape,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTrack extends StatelessWidget {
  const _SliderTrack({this.height, this.color, this.shape});

  final double? height;
  final Color? color;
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: Material(color: color, shape: shape));
  }
}

class _SliderHandle extends StatelessWidget {
  const _SliderHandle({this.size, this.color, this.shape, this.padding});

  final Size? size;
  final Color? color;
  final OutlinedBorder? shape;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Material(
        color: color,
        shape: shape,
        child: AnimatedSize(
          duration: Durations.short2,
          alignment: Alignment.center,
          child: SizedBox.fromSize(size: size),
        ),
      ),
    );
  }
}

class _SliderValueIndicator extends StatelessWidget {
  const _SliderValueIndicator({
    required _BetterRangeSliderState state,
    this.size,
    this.color,
    this.textStyle,
    this.shape,
    this.bottomSpacing,
  }) : _sliderState = state;

  final _BetterRangeSliderState _sliderState;

  final Size? size;
  final Color? color;
  final OutlinedBorder? shape;
  final TextStyle? textStyle;
  final double? bottomSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing ?? 0),
      child: Material(
        color: color,
        shape: shape,
        child: SizedBox.fromSize(
          size: size,
          child: Center(
            child: Text(_sliderState.widget.value.toStringAsFixed(0), style: textStyle),
          ),
        ),
      ),
    );
  }
}
