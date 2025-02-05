import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/utils/textstyle_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class TargetTempTile extends StatelessWidget {
  TargetTempTile({super.key});

  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  final double temperature = 64;

  static const double _temperatureChangeStep = .5;
  static const double _defaultTargetTemperature = 20;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Observer(builder: (context) {
            return HeaterModeSelect(
              currentStatus: _heaterControllerStateStore.state?.status,
              onSelected: (value) => _heaterControllerStateStore.changeMode(
                value,
              ),
            );
          }),
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Spacer(),
                  Row(
                    children: [
                      Spacer(),
                      Observer(builder: (context) {
                        double? targetTemperature =
                            _heaterControllerStateStore.targetTemperature;
                        double? lastRequestedTarget =
                            _heaterControllerStateStore
                                .lastRequestedTemperature;

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
            VerticalDivider(indent: 16, endIndent: 16, width: 0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      double currentTarget = _heaterControllerStateStore
                              .lastRequestedTemperature ??
                          _defaultTargetTemperature;

                      _heaterControllerStateStore.changeTargetTemperature(
                        currentTarget + _temperatureChangeStep,
                      );
                    },
                    icon: Icon(MdiIcons.arrowUpDropCircleOutline),
                    iconSize: 60,
                  ),
                  IconButton(
                    onPressed: () {
                      double currentTarget = _heaterControllerStateStore
                              .lastRequestedTemperature ??
                          _defaultTargetTemperature;

                      _heaterControllerStateStore.changeTargetTemperature(
                        currentTarget - _temperatureChangeStep,
                      );
                    },
                    icon: Icon(MdiIcons.arrowDownDropCircleOutline),
                    iconSize: 60,
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class HeaterModeSelect extends StatelessWidget {
  final HeaterStatus? currentStatus;
  final void Function(HeaterMode)? onSelected;

  const HeaterModeSelect({
    super.key,
    this.onSelected,
    this.currentStatus,
  });

  IconData statusToIcon(HeaterStatus? value) => switch (value) {
        HeaterStatus.heatingManual => MdiIcons.percentCircleOutline,
        HeaterStatus.heatingPid => MdiIcons.thermometerAuto,
        HeaterStatus.idle => MdiIcons.sleep,
        HeaterStatus.error => MdiIcons.kettleAlertOutline,
        HeaterStatus.unknown => MdiIcons.helpCircleOutline,
        null => MdiIcons.dotsVerticalCircleOutline,
      };

  @override
  Widget build(BuildContext context) {
    HeaterMode? initialValue;
    if (currentStatus != null) {
      initialValue = HeaterMode.fromHeaterStatus(currentStatus!);
    }

    return PopupMenuButton<HeaterMode>(
      icon: Icon(statusToIcon(currentStatus)),
      initialValue: initialValue,
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => [
        HeaterMode.idle,
        HeaterMode.heatingPid,
        HeaterMode.heatingManual,
      ]
          .map((v) => PopupMenuItem<HeaterMode>(
                value: v,
                child: Row(
                  children: [
                    Icon(statusToIcon(v.toHeaterStatus())),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                    Text(v.jsonValue),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
