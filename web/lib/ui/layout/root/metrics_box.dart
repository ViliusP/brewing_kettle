import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/app_debugging/app_debugging_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class MetricsBox extends StatelessWidget {
  final AppDebuggingStore _appDebuggingStore = getIt<AppDebuggingStore>();

  MetricsBox({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = ColorScheme.of(context);
    final TextTheme textTheme = TextTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: colorScheme.surface,
        border: Border.all(width: 1, color: colorScheme.outline),
      ),
      width: 250,
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 28,
            padding: EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            color: colorScheme.inverseSurface,
            child: Text(
              "Metrics Box",
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onInverseSurface,
                fontFamily: AppFontFamily.firaMono.name,
              ),
            ),
          ),
          Divider(color: colorScheme.outline, height: 1, thickness: 1),
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              children: [
                Observer(
                  builder: (context) {
                    Offset? pointerPosition = _appDebuggingStore.pointerPosition;

                    String x = pointerPosition?.dx.toStringAsFixed(2) ?? "na";
                    String y = pointerPosition?.dy.toStringAsFixed(2) ?? "na";

                    return RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: textTheme.bodySmall?.copyWith(
                          fontFamily: AppFontFamily.firaMono.name,
                          height: 1,
                        ),
                        children: [
                          TextSpan(text: "Pointer Position\n"),
                          TextSpan(
                            text: "x:$x y:$y",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Text("hello"),
                Text("hello"),
                Text("hello"),
                Text("hello"),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        ],
      ),
    );
  }
}
