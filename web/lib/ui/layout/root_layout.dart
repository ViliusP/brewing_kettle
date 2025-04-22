import 'package:brew_kettle_dashboard/core/data/models/app_exceptions/app_exception.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/exception/exception_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/common/fake_browser_address_bar/fake_browser_address_bar.dart';
import 'package:brew_kettle_dashboard/ui/common/snackbar/snackbar.dart';
import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobx/mobx.dart';

class RootLayout extends StatefulWidget {
  final Widget child;

  const RootLayout({super.key, required this.child});

  @override
  State<RootLayout> createState() => _RootLayoutState();
}

class _RootLayoutState extends State<RootLayout> {
  final WebSocketConnectionStore wsConnectionStore = getIt<WebSocketConnectionStore>();
  final ExceptionStore exceptionStore = getIt<ExceptionStore>();

  ReactionDisposer? onErrorReaction;
  ReactionDisposer? connectionStatusReaction;

  @override
  void initState() {
    connectionStatusReaction = reaction(
      (_) => wsConnectionStore.status,
      (status) => handleConnectionStatus(status),
      fireImmediately: true,
    );

    onErrorReaction = reaction(
      (_) => exceptionStore.stream.value,
      (exception) => onExceptionOccured(exception),
      fireImmediately: false,
    );
    ;
    super.initState();
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

  void onExceptionOccured(AppException? exception) {
    if (exception == null) return;
    AppLocalizations localizations = AppLocalizations.of(context)!;
    AppSnackabar.error(context, exception.toLocalizedMessage(localizations));
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return Stack(
        children: [
          widget.child,
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 400,
                child: FakeBrowserAddressBar(router: GoRouter.of(context)),
              ),
            ),
          ),
        ],
      );
    }

    return widget.child;
  }

  @override
  void dispose() {
    onErrorReaction?.call();
    super.dispose();
  }
}
