import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final String title;

  const Tile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return DashboardTile(
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 32,
        ),
      ),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final Widget child;

  const DashboardTile({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      child: Center(child: child),
    );
  }
}
