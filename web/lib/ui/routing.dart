import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/layout/connected_layout.dart';
import 'package:brew_kettle_dashboard/ui/layout/root_layout.dart';
import 'package:brew_kettle_dashboard/ui/screens/connection/connection_sceen.dart';
import 'package:brew_kettle_dashboard/ui/screens/devices/devices_screen.dart';
import 'package:brew_kettle_dashboard/ui/screens/information/information_screen.dart';
import 'package:brew_kettle_dashboard/ui/screens/main/main_screen.dart';
import 'package:brew_kettle_dashboard/ui/screens/not_found_404/not_found_404_screen.dart';
import 'package:brew_kettle_dashboard/ui/screens/settings/settings_screen.dart';
import 'package:brew_kettle_dashboard/ui/screens/test/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _defaultLayoutNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'default_layout',
);
final GlobalKey<NavigatorState> _connectedLayout = GlobalKey<NavigatorState>(
  debugLabel: 'connected_layout',
);

enum AppRoute {
  main("/"),
  connection("/connection"),
  settings("/settings"),
  devices("/devices"),
  information("/information"),
  test("/test");

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
      initialLocation: AppRoute.connection.path,
      debugLogDiagnostics: true,

      errorBuilder: (context, state) {
        return NotFound404Screen();
      },

      routes: [
        ShellRoute(
          navigatorKey: _defaultLayoutNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return RootLayout(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoute.information.path,
              name: AppRoute.information.name,
              builder: (context, state) => InformationScreen(),
            ),
            GoRoute(
              path: AppRoute.connection.path,
              name: AppRoute.connection.name,
              builder: (context, state) => ConnectionScreen(),
            ),
            ShellRoute(
              navigatorKey: _connectedLayout,
              redirect: (context, state) {
                final wsConnectionStore = getIt<WebSocketConnectionStore>();
                final status = wsConnectionStore.status;
                final name = state.name;

                bool isConnected = status == WebSocketConnectionStatus.connected;

                if (!isConnected && name != AppRoute.connection.name) {
                  return AppRoute.connection.path;
                }
                if (isConnected && name == AppRoute.connection.name) {
                  return AppRoute.main.name;
                }
                return null;
              },
              builder: (BuildContext context, GoRouterState state, Widget child) {
                return ConnectedLayout(child);
              },
              routes: <RouteBase>[
                GoRoute(
                  path: AppRoute.main.path,
                  name: AppRoute.main.name,
                  builder: (context, state) => const MainScreen(),
                ),
                GoRoute(
                  path: AppRoute.settings.path,
                  name: AppRoute.settings.name,
                  builder: (context, state) => SettingsScreen(),
                ),
                GoRoute(
                  path: AppRoute.devices.path,
                  name: AppRoute.devices.name,
                  builder: (context, state) => DevicesScreen(),
                ),
                GoRoute(
                  path: AppRoute.test.path,
                  name: AppRoute.test.name,
                  builder: (context, state) => TestScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
