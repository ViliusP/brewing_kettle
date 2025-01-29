import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/target_temperature/target_temperature_store.dart';
import 'package:brew_kettle_dashboard/utils/textstyle_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class TargetTempTile extends StatelessWidget {
  TargetTempTile({super.key});

  final TargetTemperatureStore _tempStore = getIt<TargetTemperatureStore>();

  final double temperature = 64;

  static const double _temperatureChangeStep = .5;
  static const double _defaultTargetTemperature = 20;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  Observer(builder: (context) {
                    double? targetTemperature = _tempStore.targetTemperature;
                    double? lastRequestedTarget =
                        _tempStore.lastRequestedTemperature;

                    String text =
                        targetTemperature?.toStringAsFixed(1) ?? "N/A";

                    bool showLabel = lastRequestedTarget != null &&
                        lastRequestedTarget != targetTemperature;

                    String badgeTexts =
                        (lastRequestedTarget ?? 0).toStringAsFixed(1);
                    return Badge(
                      alignment: Alignment.topLeft,
                      offset: const Offset(-16, 0),
                      isLabelVisible: showLabel,
                      label: Text(badgeTexts),
                      child: Text(
                        text,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.changeWeight(FontWeight.w800),
                      ),
                    );
                  }),
                  Icon(MdiIcons.temperatureCelsius, size: 54),
                  Spacer(),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      "Tikslo temperatūra",
                      style: TextTheme.of(context).labelLarge,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: VerticalDivider(indent: 16, endIndent: 16, width: 0),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                double currentTarget = _tempStore.lastRequestedTemperature ??
                    _defaultTargetTemperature;

                _tempStore.changeTargetTemperature(
                  currentTarget + _temperatureChangeStep,
                );
              },
              icon: Icon(MdiIcons.arrowUpDropCircleOutline),
              iconSize: 60,
            ),
            IconButton(
              onPressed: () {
                double currentTarget = _tempStore.lastRequestedTemperature ??
                    _defaultTargetTemperature;

                _tempStore.changeTargetTemperature(
                  currentTarget - _temperatureChangeStep,
                );
              },
              icon: Icon(MdiIcons.arrowDownDropCircleOutline),
              iconSize: 60,
            )
          ],
        ),
        const Padding(padding: EdgeInsets.only(left: 12)),
      ],
    );
  }
}
