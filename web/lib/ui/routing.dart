import 'package:brew_kettle_dashboard/ui/layout/default_layout.dart';
import 'package:brew_kettle_dashboard/ui/screens/device_info/device_info_screen.dart';
import 'package:brew_kettle_dashboard/ui/screens/start/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _defaultLayoutNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'default_layout');

enum AppRoute {
  root("/"),
  device("/device");

  const AppRoute(this.path);

  final String path;
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
      initialLocation: AppRoute.root.path,
      debugLogDiagnostics: true,
      routes: [
        ShellRoute(
          navigatorKey: _defaultLayoutNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return DefaultLayout(body: child);
          },
          routes: <RouteBase>[
            GoRoute(
              path: AppRoute.root.path,
              name: AppRoute.root.name,
              builder: (context, state) => const StartScreen(),
            ),
            GoRoute(
              path: AppRoute.device.path,
              name: AppRoute.device.name,
              builder: (context, state) => const DeviceInfoScreen(),
            ),
          ],
        )
      ],
    );
  }
}
