import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:brew_kettle_dashboard/utils/enum_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';

class ConnectedLayout extends StatefulWidget {
  ///
  final Widget child;

  const ConnectedLayout(this.child, {super.key});

  @override
  State<ConnectedLayout> createState() => _ConnectedLayoutState();
}

class _ConnectedLayoutState extends State<ConnectedLayout> {
  int? _selectedIndex;

  @override
  void initState() {
    onRouteChange();

    AppRouter.value.routerDelegate.addListener(onRouteChange);
    super.initState();
  }

  static int? _routeToIndex(AppRoute route) {
    return switch (route) {
      AppRoute.main => 0,
      AppRoute.devices => 1,
      AppRoute.settings => 2,
      AppRoute.test => null,
      AppRoute.connection => null,
      AppRoute.information => null,
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

  void onRouteChange() {
    final config = AppRouter.value.routerDelegate.currentConfiguration;
    final screenName = config.last.route.name;
    final appRoute = AppRoute.values.byNameSafe(screenName ?? "");

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

    return Row(
      children: <Widget>[
        NavigationRail(
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
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: widget.child),
      ],
    );
  }

  @override
  void dispose() {
    AppRouter.value.routerDelegate.removeListener(onRouteChange);
    super.dispose();
  }
}
