import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/utils/textstyle_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class CurrentTempTile extends StatefulWidget {
  const CurrentTempTile({super.key});

  @override
  State<CurrentTempTile> createState() => _CurrentTempTileState();
}

class _CurrentTempTileState extends State<CurrentTempTile> {
  final HeaterControllerStateStore _temperatureStore = getIt<HeaterControllerStateStore>();

  @override
  Widget build(BuildContext context) {
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
                    text = temperature.toStringAsFixed(1);
                  }

                  return Text(
                    text,
                    style: Theme.of(context).textTheme.displayMedium?.changeWeight(FontWeight.w800),
                  );
                },
              ),
              Icon(MdiIcons.temperatureCelsius, size: 54),
            ],
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text("Temperatūra", style: TextTheme.of(context).labelLarge),
            ),
          ),
        ),
      ],
    );
  }
}
