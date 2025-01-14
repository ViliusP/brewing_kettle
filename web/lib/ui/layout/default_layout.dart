import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:brew_kettle_dashboard/utils/enum_extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DefaultLayout extends StatefulWidget {
  final Widget body;

  const DefaultLayout({
    super.key,
    required this.body,
  });

  @override
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  final WebSocketConnectionStore wsConnectionStore =
      getIt<WebSocketConnectionStore>();

  int? _selectedIndex;

  bool _navigationRailVisible = true;

  @override
  void initState() {
    onRouteChange();
    AppRouter.value.routerDelegate.addListener(onRouteChange);
    super.initState();
  }

  static int? _routeToIndex(AppRoute route) {
    return switch (route) {
      AppRoute.main => 0,
      AppRoute.device => 1,
      AppRoute.test => 2,
      _ => null,
    };
  }

  static AppRoute? _indexToRoute(int index) {
    return switch (index) {
      0 => AppRoute.main,
      1 => AppRoute.device,
      2 => AppRoute.test,
      _ => null,
    };
  }

  void onRouteChange() {
    final config = AppRouter.value.routerDelegate.currentConfiguration;
    final screenName = config.last.route.name;
    final appRoute = AppRoute.values.byNameSafe(screenName ?? "");

    bool isConnected =
        wsConnectionStore.status == WebSocketConnectionStatus.connected;

    switch (appRoute) {
      case AppRoute.connection when _navigationRailVisible:
        _navigationRailVisible = false;
        break;
      case _ when isConnected && !_navigationRailVisible:
        _navigationRailVisible = true;
        break;
      case _ when !isConnected && _navigationRailVisible:
        _navigationRailVisible = false;
        break;
      default:
        break;
    }
    if (appRoute != null) _selectedIndex = _routeToIndex(appRoute);

    setState(() {});
  }

  void onDestinatationSelected(int index) {
    AppRoute? route = _indexToRoute(index);

    if (route != null) {
      GoRouter.of(context).goNamed(route.name);
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
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                axis: Axis.horizontal,
                axisAlignment: -1,
                sizeFactor: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _navigationRailVisible
                ? NavigationRail(
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
                  )
                : null,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.body),
        ],
      ),
    );
  }

  @override
  void dispose() {
    AppRouter.value.routerDelegate.removeListener(onRouteChange);
    // _connectionReactionDispose();
    super.dispose();
  }
}
