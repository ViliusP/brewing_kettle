import 'package:brew_kettle_dashboard/core/data/models/app_exceptions/app_exception.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/connection_status.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/app_configuration/app_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/app_debugging/app_debugging_store.dart';
import 'package:brew_kettle_dashboard/stores/exception/exception_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/common/drawer_menu.dart';
import 'package:brew_kettle_dashboard/ui/common/fake_browser_address_bar/fake_browser_address_bar.dart';
import 'package:brew_kettle_dashboard/ui/common/floating_draggable/floating_draggable.dart';
import 'package:brew_kettle_dashboard/ui/common/snackbar/snackbar.dart';
import 'package:brew_kettle_dashboard/ui/layout/root/debug_menu.dart';
import 'package:brew_kettle_dashboard/ui/layout/root/metrics_box.dart';
import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
  final AppDebuggingStore appDebuggingStore = getIt<AppDebuggingStore>();

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

  Widget Function(BuildContext, bool) fakeUrlBarBuilder(bool show) {
    final ColorScheme colorScheme = ColorScheme.of(context);

    return (BuildContext context, bool draggable) {
      final BoxDecoration boxDecoration = switch (draggable) {
        true => BoxDecoration(
          border: Border.all(color: colorScheme.errorContainer, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        false => BoxDecoration(borderRadius: BorderRadius.circular(0)),
      };

      double scale = draggable ? 1.05 : 1;
      final double opacity = show ? 1 : 0;

      if (!show) {
        scale = 0;
      }

      return AnimatedOpacity(
        opacity: opacity,
        duration: Durations.short2,
        curve: Curves.easeInOut,
        child: AnimatedScale(
          scale: scale,
          duration: Durations.short2,
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          child: AnimatedContainer(
            padding: const EdgeInsets.all(8),
            duration: Durations.medium2,
            curve: Curves.easeInOut,
            alignment: Alignment.center,
            decoration: boxDecoration,
            child: FakeBrowserAddressBar(router: GoRouter.of(context)),
          ),
        ),
      );
    };
  }

  Widget Function(BuildContext, bool) debugFabBuilder(bool show) {
    final ColorScheme colorScheme = ColorScheme.of(context);

    return (BuildContext context, bool draggable) {
      final BoxDecoration boxDecoration = switch (draggable) {
        true => BoxDecoration(
          border: Border.all(color: colorScheme.errorContainer, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        false => BoxDecoration(borderRadius: BorderRadius.circular(0)),
      };

      double scale = draggable ? 1.25 : 1;
      final double opacity = show ? 1 : 0;

      if (!show) {
        scale = 0;
      }

      return AnimatedOpacity(
        opacity: opacity,
        duration: Durations.short2,
        curve: Curves.easeInOut,
        child: AnimatedScale(
          scale: scale,
          duration: Durations.short2,
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            padding: const EdgeInsets.all(8),
            duration: Durations.medium2,
            transformAlignment: Alignment.center,
            curve: Curves.easeInOut,
            decoration: boxDecoration,
            child: _DebugFab(),
          ),
        ),
      );
    };
  }

  Widget Function(BuildContext, bool) metricsBoxBuilder(bool show) {
    final ColorScheme colorScheme = ColorScheme.of(context);

    return (BuildContext context, bool draggable) {
      final BoxDecoration boxDecoration = switch (draggable) {
        true => BoxDecoration(
          border: Border.all(color: colorScheme.errorContainer, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        false => BoxDecoration(borderRadius: BorderRadius.circular(0)),
      };

      double scale = draggable ? 1.025 : 1;
      final double opacity = show ? 1 : 0;

      if (!show) {
        scale = 0;
      }

      return AnimatedOpacity(
        opacity: opacity,
        duration: Durations.short2,
        curve: Curves.easeInOut,
        child: AnimatedScale(
          scale: scale,
          duration: Durations.short2,
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            padding: const EdgeInsets.all(8),
            duration: Durations.medium2,
            transformAlignment: Alignment.center,
            curve: Curves.easeInOut,
            decoration: boxDecoration,
            child: MetricsBox(),
          ),
        ),
      );
    };
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
          Observer(
            builder: (context) {
              return FloatingDraggable(
                builder: fakeUrlBarBuilder(appConfigurationStore.fakeBrowserBarEnabled),
                onDragEvent: onUrlBarDragEvent,
                initialPosition: appConfigurationStore.fakeBrowserAddressBarPosition,
              );
            },
          ),
          Observer(
            builder: (context) {
              return FloatingDraggable(
                builder: debugFabBuilder(appConfigurationStore.isAdvancedMode),
                initialPosition: Offset.zero,
              );
            },
          ),
          Observer(
            builder: (context) {
              return FloatingDraggable(
                builder: metricsBoxBuilder(appConfigurationStore.metricsBoxEnabled),
                initialPosition: Offset.zero,
              );
            },
          ),
          Observer(
            builder: (context) {
              if (appConfigurationStore.globalPointerPositionMetricEnabled) {
                return Positioned.fill(
                  child: MouseRegion(
                    hitTestBehavior: HitTestBehavior.translucent,
                    onHover: (event) {
                      appDebuggingStore.setPointerPosition(event.position);
                    },
                  ),
                );
              }
              return SizedBox.shrink();
            },
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

class _DebugFab extends StatelessWidget {
  const _DebugFab();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.of(context);

    return IconButton.outlined(
      onPressed: () {
        DrawerMenu.show(
          context: context,
          drawerOptions: DrawerRouteOptions(barrier: DrawerRouteBarrierOptions(enable: true)),
          builder: (context) {
            return DebugMenu();
          },
        );
      },
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        iconSize: 42,
        padding: EdgeInsets.all(12),
        foregroundColor: colorScheme.onSurfaceVariant,
      ).copyWith(
        side: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return null;
          } else {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(color: colorScheme.onSurface.withAlpha(30), width: 1);
            }
            return BorderSide(color: colorScheme.outline, width: 2);
          }
        }),
      ),
      icon: Icon(MdiIcons.wrenchOutline),
    );
  }
}
