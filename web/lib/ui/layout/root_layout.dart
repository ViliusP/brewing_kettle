import 'package:brew_kettle_dashboard/core/data/models/app_exceptions/app_exception.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/app_configuration/app_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/exception/exception_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/common/fake_browser_address_bar/fake_browser_address_bar.dart';
import 'package:brew_kettle_dashboard/ui/common/floating_draggable/floating_draggable.dart';
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
  final AppConfigurationStore appConfigurationStore = getIt<AppConfigurationStore>();
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

  void onUrlBarDragEvent(DragEventDetails details) {
    switch (details.type) {
      case DragEventType.start:
      case DragEventType.move:
        return;
      case DragEventType.windowResize:
      case DragEventType.end:
        appConfigurationStore.setFakeUrlBarPosition(details.offset);
        return;
    }
  }

  Widget fakeUrlBarBuilder(BuildContext context, bool draggable) {
    final ColorScheme colorScheme = ColorScheme.of(context);
    final BoxDecoration boxDecoration = switch (draggable) {
      true => BoxDecoration(
        border: Border.all(color: colorScheme.errorContainer, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      false => BoxDecoration(borderRadius: BorderRadius.circular(0)),
    };

    return AnimatedScale(
      scale: draggable ? 1.05 : 1,
      duration: Durations.short2,
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        padding: const EdgeInsets.all(8),
        duration: Durations.medium2,
        curve: Curves.easeInOut,
        decoration: boxDecoration,
        child: FakeBrowserAddressBar(router: GoRouter.of(context)),
      ),
    );
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
          FloatingDraggable(
            builder: fakeUrlBarBuilder,
            onDragEvent: onUrlBarDragEvent,
            initialPosition: appConfigurationStore.fakeBrowserAddressBarPosition,
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
