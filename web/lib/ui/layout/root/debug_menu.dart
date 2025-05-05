import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/app_configuration/app_configuration_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class DebugMenu extends StatelessWidget {
  const DebugMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = TextTheme.of(context);

    return Material(
      shape: Border.fromBorderSide(BorderSide()),
      child: SizedBox(
        width: 400,
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
            Text("Debug Settings", style: textTheme.titleLarge),
            Text(
              "Information: you can toggle debug tools using ctrl+D",
              style: textTheme.bodySmall,
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 8.0)),
            const _DebugSettings(),
            Spacer(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.tonalIcon(
                icon: Icon(AppConstants.backIcon),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(48),
                  textStyle: textTheme.labelLarge?.copyWith(fontSize: 18),
                  iconSize: 18,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                label: Text(localizations.generalGoBack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugSettings extends StatelessWidget {
  const _DebugSettings();

  @override
  Widget build(BuildContext context) {
    final AppConfigurationStore appConfigurationStore = getIt<AppConfigurationStore>();
    final TextTheme textTheme = TextTheme.of(context);

    return Column(
      children: [
        Observer(
          builder: (context) {
            return CheckboxListTile(
              title: const Text("Fake Browser URL bar"),
              subtitle: const Text(
                'Enables fake browser URL bar to make routing manual testing easier',
              ),
              value: appConfigurationStore.fakeBrowserBarEnabled,
              onChanged: (bool? value) {
                if (value != null) appConfigurationStore.setFakeBrowserBar(value);
              },
            );
          },
        ),
        Divider(),
        Text("Metrics Box", style: textTheme.labelLarge, textAlign: TextAlign.center),
        Observer(
          builder: (context) {
            return CheckboxListTile(
              title: const Text("Global pointer position"),
              subtitle: const Text('Shows global pointer position (x,y)'),
              value: appConfigurationStore.globalPointerPositionMetricEnabled,
              onChanged: (bool? value) {
                if (value != null) appConfigurationStore.setGlobalPointerPositionMetric(value);
              },
            );
          },
        ),
      ],
    );
  }
}
