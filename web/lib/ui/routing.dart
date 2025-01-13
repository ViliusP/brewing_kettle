import 'package:brew_kettle_dashboard/ui/layout/default_layout.dart';
import 'package:brew_kettle_dashboard/ui/screens/connection/connection_sceen.dart';
import 'package:brew_kettle_dashboard/ui/screens/device_info/device_info_screen.dart';
import 'package:brew_kettle_dashboard/ui/screens/start/start_screen.dart';
import 'package:brew_kettle_dashboard/ui/screens/test/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _defaultLayoutNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'default_layout');

enum AppRoute {
  main("/", 0),
  connection("/connection", 4),
  device("/device", 1),
  test("/test", 2);

  const AppRoute(this.path, [this.layoutIndex]);

  final String path;

  final int? layoutIndex;
}

class AppRouter {
  final GoRouter _router;

  AppRouter._internal() : _router = _create();

  static final AppRouter _instance = AppRouter._internal();

  factory AppRouter() {
    return _instance;
  }

  static GoRouter get value => _instance._router;

  static GoRouter _create() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoute.connection.path,
      debugLogDiagnostics: true,
      routes: [
        ShellRoute(
          navigatorKey: _defaultLayoutNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return DefaultLayout(
              initialRouteIndex: tabIndexFromCurrentRoute(context),
              body: child,
            );
          },
          routes: <RouteBase>[
            GoRoute(
              path: AppRoute.connection.path,
              name: AppRoute.connection.name,
              builder: (context, state) => const ConnectionScreen(),
            ),
            GoRoute(
              path: AppRoute.main.path,
              name: AppRoute.main.name,
              builder: (context, state) => const MainScreen(),
            ),
            GoRoute(
              path: AppRoute.device.path,
              name: AppRoute.device.name,
              builder: (context, state) => DeviceInfoScreen(),
            ),
            GoRoute(
              path: AppRoute.test.path,
              name: AppRoute.test.name,
              builder: (context, state) => TestScreen(),
            ),
          ],
        )
      ],
    );
  }

  static int tabIndexFromCurrentRoute(BuildContext context) {
    final String? routeName = GoRouterState.of(context).topRoute?.name;
    try {
      return AppRoute.values.byName(routeName ?? "").layoutIndex ?? 0;
      // ignore: empty_catches
    } catch (e) {
      return 0;
    }
  }
}
