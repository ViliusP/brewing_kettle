import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class SuggestionsRow extends StatefulWidget {
  final Widget? trailing;
  final Widget child;

  const SuggestionsRow({
    super.key,
    required this.child,
    this.trailing,
  });

  @override
  State<SuggestionsRow> createState() => _SuggestionsRowState();
}

class _SuggestionsRowState extends State<SuggestionsRow> {
  final ScrollController _suggestionRowScrollController = ScrollController();

  bool _isScrollableToLeft = false; // Store scrollable state to the left
  bool _isScrollableToRight = false; // Store scrollable state to the right

  @override
  void initState() {
    super.initState();
    // Listen to scroll changes
    _suggestionRowScrollController.addListener(_checkScrollable);
    // Check after layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScrollable());
  }

  @override
  void didUpdateWidget(covariant SuggestionsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check scrollable state when widget updates
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkScrollable());
  }

  void _checkScrollable() {
    if (_suggestionRowScrollController.hasClients) {
      var scrollPosition = _suggestionRowScrollController.position;
      setState(() {
        _isScrollableToRight = scrollPosition.extentAfter > 0;
        _isScrollableToLeft = scrollPosition.extentBefore > 0;
      });
    }
  }

  List<ColorStop> colorStops(
    bool isScrollableToLeft,
    bool isScrollableToRight,
  ) {
    if (isScrollableToLeft && isScrollableToRight) {
      return const [
        ColorStop(stop: 0.0, color: Color.fromARGB(215, 255, 255, 255)),
        ColorStop(stop: 0.02, color: Colors.transparent),
        ColorStop(stop: 0.98, color: Colors.transparent),
        ColorStop(stop: 1, color: Color.fromARGB(215, 255, 255, 255)),
      ];
    }
    if (isScrollableToLeft) {
      return const [
        ColorStop(stop: 0.0, color: Color.fromARGB(215, 255, 255, 255)),
        ColorStop(stop: 0.02, color: Colors.transparent),
      ];
    }
    if (isScrollableToRight) {
      return const [
        ColorStop(stop: 0.98, color: Colors.transparent),
        ColorStop(stop: 1, color: Color.fromARGB(215, 255, 255, 255)),
      ];
    }
    return const [
      ColorStop(stop: 0.0, color: Colors.transparent),
      ColorStop(stop: 1.0, color: Colors.transparent),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FadedEdges(
            axis: Axis.horizontal,
            colorStops: colorStops(
              _isScrollableToLeft,
              _isScrollableToRight,
            ),
            child: SingleChildScrollView(
              controller: _suggestionRowScrollController,
              scrollDirection: Axis.horizontal,
              child: AnimatedSize(
                alignment: Alignment.centerLeft,
                duration: Durations.short3,
                curve: Curves.bounceInOut,
                reverseDuration: Durations.medium2,
                child: widget.child,
              ),
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          Padding(padding: EdgeInsets.symmetric(horizontal: 12)),
          widget.trailing!,
        ],
      ],
    );
  }

  @override
  void dispose() {
    _suggestionRowScrollController.dispose();
    super.dispose();
  }
}

class IpSuggestionChip extends StatelessWidget {
  final String text;
  final String? tooltip;
  final bool selected;
  final void Function(bool) onSelected;

  const IpSuggestionChip({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.text,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(text),
      tooltip: tooltip,
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class ScanDevicesChip extends StatelessWidget {
  final void Function()? onPressed;

  final bool loading;

  const ScanDevicesChip({
    super.key,
    this.loading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onPressed,
      avatar: AnimatedSwitcher(
        duration: Durations.short3,
        child: switch (loading) {
          true => SizedBox.fromSize(
              key: ValueKey(true),
              size: Size.square(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          false => Icon(MdiIcons.refresh, key: ValueKey(false)),
        },
      ),
      label: const Text('Scan'),
    );
  }
}

/// ```dart
/// const colors = [
///   Colors.white.withOpacity(0.80),
///   Colors.transparent,
///   Colors.transparent,
///   Colors.white.withOpacity(0.80)
/// ]
///
/// const stops = const [0.1, 0.15, 0.85, 1.0]
/// ```
class FadedEdges extends StatelessWidget {
  final List<ColorStop> colorStops;
  final Axis axis;
  final Widget child;

  const FadedEdges({
    super.key,
    this.colorStops = const [],
    this.axis = Axis.vertical,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Alignment begin = switch (axis) {
      Axis.vertical => Alignment.topCenter,
      Axis.horizontal => Alignment.centerLeft,
    };

    Alignment end = switch (axis) {
      Axis.vertical => Alignment.bottomCenter,
      Axis.horizontal => Alignment.centerRight,
    };

    return ShaderMask(
      blendMode: BlendMode.dstOut,
      shaderCallback: (Rect rect) => LinearGradient(
        colors: colorStops.map((e) => e.color).toList(),
        stops: colorStops.map((e) => e.stop).toList(),
        begin: begin,
        end: end,
      ).createShader(rect),
      child: child,
    );
  }
}

class ColorStop {
  final double stop;
  final Color color;

  const ColorStop({
    required this.stop,
    required this.color,
  });
}
