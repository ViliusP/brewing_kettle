import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class PaginationControl extends StatefulWidget {
  /// Current page
  final int? current;

  /// Size of section
  final int section;

  /// Total number of pages
  final int total;

  /// Callback when value are changed.
  ///
  /// Values are changed on:
  /// - Number button tap;
  /// - Arrow control buttons tap;
  final void Function(int)? onChanged;

  const PaginationControl({
    super.key,
    required this.current,
    required this.section,
    required this.total,
    this.onChanged,
  });

  @override
  State<PaginationControl> createState() => _PaginationControlState();
}

class _PaginationControlState extends State<PaginationControl> {
  _HorizontalDirection movement = _HorizontalDirection.right;

  List generatePaginationNumbers() {
    int current = widget.current ?? 1;
    int section = widget.section.clamp(0, widget.total);
    if (section == 0) {
      return [];
    }

    int offset = current;

    int maxOffset = widget.total - section + 1;
    if (maxOffset < 1) {
      maxOffset = 1;
    }

    offset = offset.clamp(1, maxOffset);
    return List.generate(
      section.clamp(0, widget.total),
      (i) => offset + i,
      growable: false,
    );
  }

  void _changePage(int value) {
    int nextPage = value.clamp(1, widget.total);
    if (nextPage != widget.current) {
      widget.onChanged?.call(nextPage);
    }
  }

  @override
  void didUpdateWidget(covariant PaginationControl oldWidget) {
    int lastPage = oldWidget.current ?? 1;
    int newPage = widget.current ?? 1;
    movement = switch (lastPage > newPage) {
      true => _HorizontalDirection.left,
      false => _HorizontalDirection.right,
    };
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    int currentPage = widget.current ?? 1;
    int firstPage = 1;
    int previousPage = currentPage - 1;
    int nextPage = currentPage + 1;
    int lastPage = widget.total;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        IconButton.outlined(
          onPressed: () => _changePage(firstPage),
          icon: Icon(MdiIcons.pageFirst),
        ),
        IconButton.outlined(
          onPressed: () => _changePage(previousPage),
          icon: Icon(MdiIcons.arrowLeft),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
        ...generatePaginationNumbers().map(
          (i) => _PaginationNumberButton(
            i,
            onPressed: (i) => _changePage(i),
            selected: i == currentPage,
            slideDirection: movement,
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
        IconButton.outlined(
          onPressed: () => _changePage(nextPage),
          icon: Icon(MdiIcons.arrowRight),
        ),
        IconButton.outlined(
          onPressed: () => _changePage(lastPage),
          icon: Icon(MdiIcons.pageLast),
        ),
      ],
    );
  }
}

class _PaginationNumberButton extends StatelessWidget {
  final int number;
  final bool selected;
  final void Function(int value)? onPressed;
  final _HorizontalDirection? slideDirection;

  const _PaginationNumberButton(
    this.number, {
    this.onPressed,
    this.selected = false,
    this.slideDirection,
  });

  static String _intToIconsText(int value) {
    String stringInt = value.toString();

    String text = "";
    for (int i = 0; i < stringInt.length; i++) {
      MdiIcons? icon = switch (stringInt[i]) {
        "-" => MdiIcons.minus,
        "0" => MdiIcons.numeric0,
        "1" => MdiIcons.numeric1,
        "2" => MdiIcons.numeric2,
        "3" => MdiIcons.numeric3,
        "4" => MdiIcons.numeric4,
        "5" => MdiIcons.numeric5,
        "6" => MdiIcons.numeric6,
        "7" => MdiIcons.numeric7,
        "8" => MdiIcons.numeric8,
        "9" => MdiIcons.numeric9,
        _ => null,
      };
      if (icon != null) {
        String char = String.fromCharCode(icon.codePoint);
        if (text.isNotEmpty) text += " ";
        text += char;
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle tonalButtonStyle = FilledButton.tonal(
      onPressed: () {},
      child: null,
    ).defaultStyleOf(context);

    double radius = 12.0;
    if (selected) {
      radius = 4.0;
    }

    String text = _intToIconsText(number);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 7),
        minimumSize: Size(48, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ).copyWith(
        backgroundColor: selected ? tonalButtonStyle.backgroundColor : null,
        textStyle: selected ? tonalButtonStyle.textStyle : null,
      ),
      onPressed: onPressed != null ? () => onPressed!(number) : null,
      child: AnimatedSwitcher(
        transitionBuilder: (Widget child, Animation<double> animation) {
          final Offset begin = switch (slideDirection) {
            _HorizontalDirection.right => Offset(-2.0, 0),
            _HorizontalDirection.left => Offset(2, 0),
            null => Offset.zero,
          };

          final Animation<Offset> offset = Tween<Offset>(
            begin: begin,
            end: Offset(0, 0),
          ).animate(animation);

          return SlideTransition(
            key: child.key,
            position: offset,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        duration: Durations.short2,
        reverseDuration: Durations.short2,
        child: Text(key: ValueKey(number), text),
      ),
    );
  }
}

enum _HorizontalDirection {
  left,
  right;
}
