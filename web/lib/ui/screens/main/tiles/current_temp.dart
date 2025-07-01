import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/app_configuration/app_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/ui/screens/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CurrentTempTile extends StatefulWidget {
  const CurrentTempTile({super.key});

  @override
  State<CurrentTempTile> createState() => _CurrentTempTileState();
}

class _CurrentTempTileState extends State<CurrentTempTile> {
  final HeaterControllerStateStore _temperatureStore = getIt<HeaterControllerStateStore>();
  final AppConfigurationStore _appConfigurationStore = getIt<AppConfigurationStore>();

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Spacer(),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Observer(
                builder: (context) {
                  double? temperature = _temperatureStore.currentTemperature;
                  String text = "X.X";
                  if (temperature != null) {
                    temperature = _appConfigurationStore.temperatureScale.fromCelsius(temperature);
                    text = temperature.toStringAsFixed(1);
                  }

                  return Text(
                    text,
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
                  );
                },
              ),
              Icon(_appConfigurationStore.temperatureScale.icon, size: 54),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                localizations.generalTemperature,
                style: TextTheme.of(context).labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
