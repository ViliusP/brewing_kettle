import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/ui/common/idle_circles/idle_circles.dart';
import 'package:brew_kettle_dashboard/utils/textstyle_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class HeaterControlTile extends StatelessWidget {
  HeaterControlTile({super.key});

  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  final double temperature = 64;

  static const double _temperatureChangeStep = .5;
  static const double _defaultTargetTemperature = 20;
  static const double _defaultPower = 0;
  static const double _powerChangeStep = 5;

  void increaseHeatingPid() {
    double currentTarget =
        _heaterControllerStateStore.lastRequestedTemperature ??
            _defaultTargetTemperature;

    _heaterControllerStateStore.changeTargetTemperature(
      currentTarget + _temperatureChangeStep,
    );
  }

  void increaseHeatingManual() {
    double currentPower =
        _heaterControllerStateStore.lastRequestedPower ?? _defaultPower;

    _heaterControllerStateStore.changePower(
      currentPower + _powerChangeStep,
    );
  }

  void decreaseHeatingPid() {
    double currentTarget =
        _heaterControllerStateStore.lastRequestedTemperature ??
            _defaultTargetTemperature;

    _heaterControllerStateStore.changeTargetTemperature(
      currentTarget - _temperatureChangeStep,
    );
  }

  void decreaseHeatingManual() {
    double currentPower =
        _heaterControllerStateStore.lastRequestedPower ?? _defaultPower;

    _heaterControllerStateStore.changePower(
      currentPower - _powerChangeStep,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Observer(builder: (context) {
            return _HeaterModeSelect(
              currentStatus: _heaterControllerStateStore.status,
              onSelected: (value) => _heaterControllerStateStore.changeMode(
                value,
              ),
            );
          }),
        ),
        Row(
          children: [
            Expanded(child: Observer(builder: (context) {
              switch (_heaterControllerStateStore.status) {
                case HeaterStatus.unknown:
                  return _PidControlContent();
                case HeaterStatus.idle:
                  return _IdleStatusContent();
                case HeaterStatus.heatingPid:
                  return _PidControlContent();
                case HeaterStatus.heatingManual:
                  return _ManualControlContent();
                case HeaterStatus.error:
                  return _PidControlContent();
                case null:
                  return _PidControlContent();
              }
            })),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Observer(builder: (context) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: switch (_heaterControllerStateStore.status) {
                        HeaterStatus.heatingPid => increaseHeatingPid,
                        HeaterStatus.idle => null,
                        HeaterStatus.heatingManual => increaseHeatingManual,
                        HeaterStatus.error => null,
                        HeaterStatus.unknown => null,
                        null => null,
                      },
                      icon: Icon(MdiIcons.arrowUpDropCircleOutline),
                      iconSize: 60,
                    ),
                    IconButton(
                      onPressed: switch (_heaterControllerStateStore.status) {
                        HeaterStatus.heatingPid => decreaseHeatingPid,
                        HeaterStatus.idle => null,
                        HeaterStatus.heatingManual => decreaseHeatingManual,
                        HeaterStatus.error => null,
                        HeaterStatus.unknown => null,
                        null => null,
                      },
                      icon: Icon(MdiIcons.arrowDownDropCircleOutline),
                      iconSize: 60,
                    )
                  ],
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _ManualControlContent extends StatelessWidget {
  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  _ManualControlContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Row(
          children: [
            Spacer(),
            Observer(builder: (context) {
              double? power = _heaterControllerStateStore.power;
              double? lastRequestedPower =
                  _heaterControllerStateStore.lastRequestedPower;

              String text = power?.toStringAsFixed(0) ?? "N/A";

              bool showLabel =
                  lastRequestedPower != null && lastRequestedPower != power;

              String badgeTexts = (lastRequestedPower ?? 0).toStringAsFixed(0);
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
            Icon(MdiIcons.percentOutline, size: 54),
            Spacer(),
          ],
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                "Galia",
                style: TextTheme.of(context).labelLarge,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _PidControlContent extends StatelessWidget {
  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  _PidControlContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Row(
          children: [
            Spacer(),
            Observer(builder: (context) {
              double? targetTemperature =
                  _heaterControllerStateStore.targetTemperature;
              double? lastRequestedTarget =
                  _heaterControllerStateStore.lastRequestedTemperature;

              String text = targetTemperature?.toStringAsFixed(1) ?? "N/A";

              bool showLabel = lastRequestedTarget != null &&
                  lastRequestedTarget != targetTemperature;

              String badgeTexts = (lastRequestedTarget ?? 0).toStringAsFixed(1);
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
    );
  }
}

class _IdleStatusContent extends StatelessWidget {
  const _IdleStatusContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: AnimatedIdleCircles()),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            "Pauzė",
            style: TextTheme.of(context).labelLarge,
          ),
        )
      ],
    );
  }
}

class _HeaterModeSelect extends StatelessWidget {
  final HeaterStatus? currentStatus;
  final void Function(HeaterMode)? onSelected;

  const _HeaterModeSelect({
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
      iconSize: 36,
      tooltip: "Kaitinimo būdas ${initialValue?.jsonValue}",
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
