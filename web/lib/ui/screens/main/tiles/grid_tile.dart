import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final Widget child;
  final bool outlined;

  const DashboardTile({
    super.key,
    required this.child,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    var shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12.0)),
    );

    if (outlined) {
      shape = shape.copyWith(
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      );
      return Card.outlined(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        elevation: 0,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: Center(child: child),
      );
    }

    return Card.filled(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      elevation: 0,
      shape: shape,
      color: colorScheme.surfaceContainer,
      clipBehavior: Clip.hardEdge,
      child: Center(child: child),
    );
  }
}
