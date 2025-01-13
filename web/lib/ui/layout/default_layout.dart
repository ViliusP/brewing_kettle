import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DefaultLayout extends StatefulWidget {
  final Widget body;

  const DefaultLayout({super.key, required this.body});

  @override
  State<DefaultLayout> createState() => _NavRailExampleState();
}

class _NavRailExampleState extends State<DefaultLayout> {
  int _selectedIndex = 0;

  void onDestinatationSelected(int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).goNamed(AppRoute.root.name);
        break;
      case 1:
        GoRouter.of(context).goNamed(AppRoute.device.name);
      case 2:
        GoRouter.of(context).goNamed(AppRoute.root.name);
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            groupAlignment: -1,
            onDestinationSelected: onDestinatationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: Text('First'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark_border),
                selectedIcon: Icon(Icons.book),
                label: Text('Second'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star_border),
                selectedIcon: Icon(Icons.star),
                label: Text('Third'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.body),
        ],
      ),
    );
  }
}
