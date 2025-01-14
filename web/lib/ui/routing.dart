import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
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
  main("/"),
  connection("/connection"),
  device("/device"),
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
      routes: [
        ShellRoute(
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
          navigatorKey: _defaultLayoutNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return DefaultLayout(body: child);
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
}
