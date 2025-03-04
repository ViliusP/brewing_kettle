import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:brew_kettle_dashboard/utils/enum_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';

class DefaultLayout extends StatefulWidget {
  final Widget body;

  const DefaultLayout({super.key, required this.body});

  @override
  State<DefaultLayout> createState() => _DefaultLayoutState();
}

class _DefaultLayoutState extends State<DefaultLayout> {
  final WebSocketConnectionStore wsConnectionStore = getIt<WebSocketConnectionStore>();

  int? _selectedIndex;
  late final ReactionDisposer _connectedReaction;
  bool _navigationRailVisible = true;

  @override
  void initState() {
    onRouteChange();
    _connectedReaction = reaction(
      (_) => wsConnectionStore.status,
      (status) => handleConnectionStatus(status),
      fireImmediately: true,
    );
    AppRouter.value.routerDelegate.addListener(onRouteChange);
    super.initState();
  }

  static int? _routeToIndex(AppRoute route) {
    return switch (route) {
      AppRoute.main => 0,
      AppRoute.devices => 1,
      AppRoute.settings => 2,
      AppRoute.test => 3,
      AppRoute.connection => null,
    };
  }

  static AppRoute? _indexToRoute(int index) {
    return switch (index) {
      0 => AppRoute.main,
      1 => AppRoute.devices,
      2 => AppRoute.settings,
      3 => AppRoute.test,
      _ => null,
    };
  }

  void handleConnectionStatus(WebSocketConnectionStatus status) {
    switch (status) {
      case WebSocketConnectionStatus.connected:
        context.replaceNamed(AppRoute.main.name);
        break;
      case WebSocketConnectionStatus.connecting:
        break;
      case _:
        var currentPath = GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration.uri.path;
        if (currentPath != AppRoute.connection.path) {
          context.replaceNamed(AppRoute.main.name);
        }
        break;
    }
  }

  void onErrorOccured() {
    AppSnackabar.error(context, "hello world");
  }

  void onRouteChange() {
    final config = AppRouter.value.routerDelegate.currentConfiguration;
    final screenName = config.last.route.name;
    final appRoute = AppRoute.values.byNameSafe(screenName ?? "");

    bool isConnected = wsConnectionStore.status == WebSocketConnectionStatus.connected;

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
    final config = AppRouter.value.routerDelegate.currentConfiguration;
    final currentScreen = config.last.route.path;

    if (route != null && route.path != currentScreen) {
      GoRouter.of(context).goNamed(route.name);
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

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
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child:
                _navigationRailVisible
                    ? NavigationRail(
                      selectedIndex: _selectedIndex,
                      groupAlignment: 0,
                      onDestinationSelected: onDestinatationSelected,
                      labelType: NavigationRailLabelType.all,
                      destinations: <NavigationRailDestination>[
                        NavigationRailDestination(
                          icon: Icon(MdiIcons.viewDashboardOutline),
                          selectedIcon: Icon(MdiIcons.viewDashboard),
                          label: Text(localizations.layoutItemHome),
                        ),
                        NavigationRailDestination(
                          icon: Icon(MdiIcons.cpu32Bit),
                          selectedIcon: Icon(MdiIcons.cpu32Bit),
                          label: Text(localizations.layoutItemDevices),
                        ),
                        NavigationRailDestination(
                          icon: Icon(MdiIcons.cogOutline),
                          selectedIcon: Icon(MdiIcons.cog),
                          label: Text(localizations.layoutItemSettings),
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
    _connectedReaction.call();
    super.dispose();
  }
}
