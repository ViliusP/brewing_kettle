import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';

class DefaultLayout extends StatefulWidget {
  final int initialRouteIndex;

  final Widget body;

  const DefaultLayout({
    super.key,
    this.initialRouteIndex = 0,
    required this.body,
  });

  @override
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  final WebSocketConnectionStore wsConnectionStore =
      getIt<WebSocketConnectionStore>();

  late final ReactionDisposer _connectionReactionDispose;

  late int _selectedIndex = widget.initialRouteIndex;

  @override
  void initState() {
    _connectionReactionDispose = reaction(
      (_) => wsConnectionStore.status,
      onConnectionState,
      fireImmediately: true,
    );
    super.initState();
  }

  void onConnectionState(WebSocketConnectionStatus status) {
    print("Current status ${status}");
  }

  void onDestinatationSelected(int index) {
    switch (index) {
      case 0:
        GoRouter.of(context).goNamed(AppRoute.main.name);
        break;
      case 1:
        GoRouter.of(context).goNamed(AppRoute.device.name);
      case 2:
        GoRouter.of(context).goNamed(AppRoute.connection.name);
      case 3:
        GoRouter.of(context).goNamed(AppRoute.test.name);
      case 4:
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog.fullscreen(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('This is a fullscreen dialog.'),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );

      case 4:
        GoRouter.of(context).goNamed(AppRoute.connection.name);
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
            destinations: <NavigationRailDestination>[
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
              NavigationRailDestination(
                icon: Icon(Icons.abc_rounded),
                selectedIcon: Icon(Icons.ac_unit),
                label: Text('Fourth'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.abc_rounded),
                selectedIcon: Icon(Icons.ac_unit),
                label: Text(
                  GoRouter.of(context)
                      .routeInformationProvider
                      .value
                      .uri
                      .toString(),
                ),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.body),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _connectionReactionDispose();
    super.dispose();
  }
}
