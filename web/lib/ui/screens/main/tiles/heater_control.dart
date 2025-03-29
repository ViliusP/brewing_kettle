import 'dart:async';

import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/ui/common/idle_circles/idle_circles.dart';
import 'package:brew_kettle_dashboard/ui/common/slider_container/slider_container.dart';
import 'package:brew_kettle_dashboard/utils/textstyle_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

class HeaterControlTile extends StatefulWidget {
  const HeaterControlTile({super.key});

  @override
  State<HeaterControlTile> createState() => _HeaterControlTileState();
}

class _HeaterControlTileState extends State<HeaterControlTile> {
  static const double _defaultPower = 0;
  static const double _powerChangeStep = 5;

  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  final ButtonTapNotifier _increaseTapNotifier = ButtonTapNotifier();
  final ButtonTapNotifier _decreaseTapNotifier = ButtonTapNotifier();

  void increaseHeatingManual() {
    double currentPower = _heaterControllerStateStore.requestedPower ?? _defaultPower;

    _heaterControllerStateStore.changePower(currentPower + _powerChangeStep);
  }

  void decreaseHeatingManual() {
    double currentPower = _heaterControllerStateStore.requestedPower ?? _defaultPower;

    _heaterControllerStateStore.changePower(currentPower - _powerChangeStep);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Observer(
          builder: (context) {
            if (_heaterControllerStateStore.isModeChanging) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: LinearProgressIndicator(borderRadius: BorderRadius.circular(16)),
              );
            }
            return SizedBox.shrink();
          },
        ),
        Row(
          children: [
            Expanded(
              child: Observer(
                builder: (context) {
                  return AnimatedSwitcher(
                    duration: Durations.short4,
                    child: switch (_heaterControllerStateStore.status) {
                      HeaterStatus.heatingPid => _PidControlContent(
                        increaseNotifier: _increaseTapNotifier,
                        decreaseNotifier: _decreaseTapNotifier,
                      ),
                      HeaterStatus.autotunePid => _PidAutotuneContent(),
                      HeaterStatus.heatingManual => _ManualControlContent(
                        increaseNotifier: _increaseTapNotifier,
                        decreaseNotifier: _decreaseTapNotifier,
                      ),
                      HeaterStatus.unknown => _PidControlContent(),
                      HeaterStatus.idle => _IdleStatusContent(),
                      HeaterStatus.error => _PidControlContent(),
                      null => _PidControlContent(),
                    },
                  );
                },
              ),
            ),
            VerticalDivider(width: 0, color: colorScheme.outlineVariant.withAlpha(255 ~/ 2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Observer(
                builder: (context) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: switch (_heaterControllerStateStore.status) {
                          HeaterStatus.heatingPid ||
                          HeaterStatus.heatingManual => _increaseTapNotifier.notify,
                          HeaterStatus.autotunePid => null,
                          HeaterStatus.idle => null,
                          HeaterStatus.error => null,
                          HeaterStatus.unknown => null,
                          null => null,
                        },
                        icon: Icon(MdiIcons.arrowUpDropCircleOutline),
                        iconSize: 60,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Observer(
                          builder: (context) {
                            return _HeaterModeSelect(
                              currentStatus: _heaterControllerStateStore.status,
                              onSelected: (value) => _heaterControllerStateStore.changeMode(value),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: switch (_heaterControllerStateStore.status) {
                          HeaterStatus.heatingPid ||
                          HeaterStatus.heatingManual => _decreaseTapNotifier.notify,
                          HeaterStatus.idle => null,
                          HeaterStatus.autotunePid => null,
                          HeaterStatus.error => null,
                          HeaterStatus.unknown => null,
                          null => null,
                        },
                        icon: Icon(MdiIcons.arrowDownDropCircleOutline),
                        iconSize: 60,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _increaseTapNotifier.dispose();
    _decreaseTapNotifier.dispose();
    super.dispose();
  }
}

class _ManualControlContent extends StatefulWidget {
  final ButtonTapNotifier? increaseNotifier;
  final ButtonTapNotifier? decreaseNotifier;

  const _ManualControlContent({this.increaseNotifier, this.decreaseNotifier});

  @override
  State<_ManualControlContent> createState() => _ManualControlContentState();
}

class _ManualControlContentState extends State<_ManualControlContent> {
  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  static const double _powerChangeStep = 1;

  double _targetPower = 0;
  Timer? _debounce;
  late final ReactionDisposer _powerTargetReaction;

  @override
  void initState() {
    _targetPower = _heaterControllerStateStore.targetTemperature ?? 0;

    widget.increaseNotifier?.addListener(increaseTemperature);
    widget.decreaseNotifier?.addListener(decreaseTemperature);

    _powerTargetReaction = reaction(
      (_) => _heaterControllerStateStore.power,
      onStoreTargetTempChange,
      fireImmediately: true,
    );
    super.initState();
  }

  void onStoreTargetTempChange(double? value) {
    if (value != _targetPower) {
      setState(() {
        _targetPower = value ?? 0;
      });
    }
  }

  void increaseTemperature() {
    _updateTarget(_targetPower + _powerChangeStep);
  }

  void decreaseTemperature() {
    _updateTarget(_targetPower - _powerChangeStep);
  }

  void _updateTarget(double value) {
    setState(() {
      _targetPower = value.clamp(0, 100);
    });

    // Reset the timer if it's already running
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _heaterControllerStateStore.changePower(_targetPower);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return SliderContainer(
      direction: AxisDirection.up,
      onChanged: _updateTarget,
      step: 1,
      range: RangeValues(0, 100),
      value: _targetPower,
      child: Column(
        children: [
          Spacer(),
          Row(
            children: [
              Spacer(),
              Observer(
                builder: (context) {
                  double? storePower = _heaterControllerStateStore.power;
                  double? lastRequestedTarget = _heaterControllerStateStore.requestedPower;

                  String text = storePower?.toStringAsFixed(1) ?? "N/A";

                  bool showLabel =
                      _targetPower != lastRequestedTarget ||
                      (lastRequestedTarget != null && lastRequestedTarget != storePower);

                  String badgeTexts = _targetPower.toStringAsFixed(0);
                  return Badge(
                    alignment: Alignment.topLeft,
                    offset: const Offset(-16, 0),
                    isLabelVisible: showLabel,
                    label: Text(badgeTexts),
                    child: Text(
                      text,
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.changeWeight(FontWeight.w800),
                    ),
                  );
                },
              ),
              Icon(MdiIcons.percentOutline, size: 54),
              Spacer(),
            ],
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(appLocalizations.generalPower, style: TextTheme.of(context).labelLarge),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.increaseNotifier?.removeListener(increaseTemperature);
    widget.decreaseNotifier?.removeListener(decreaseTemperature);

    _debounce?.cancel();

    _powerTargetReaction.call();
    super.dispose();
  }
}

class _PidControlContent extends StatefulWidget {
  final ButtonTapNotifier? increaseNotifier;
  final ButtonTapNotifier? decreaseNotifier;

  const _PidControlContent({this.increaseNotifier, this.decreaseNotifier});

  @override
  State<_PidControlContent> createState() => _PidControlContentState();
}

class _PidControlContentState extends State<_PidControlContent> {
  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  static const double _temperatureChangeStep = 1;

  double _targetTemp = 0;
  Timer? _debounce;
  late final ReactionDisposer _temperatureTargetReaction;

  @override
  void initState() {
    _targetTemp = _heaterControllerStateStore.targetTemperature ?? 0;

    widget.increaseNotifier?.addListener(increaseTemperature);
    widget.decreaseNotifier?.addListener(decreaseTemperature);

    _temperatureTargetReaction = reaction(
      (_) => _heaterControllerStateStore.targetTemperature,
      onStoreTargetTempChange,
      fireImmediately: true,
    );
    super.initState();
  }

  void onStoreTargetTempChange(double? value) {
    if (value != _targetTemp) {
      setState(() => _targetTemp = value ?? 0);
    }
  }

  void increaseTemperature() {
    _updateTarget(_targetTemp + _temperatureChangeStep);
  }

  void decreaseTemperature() {
    _updateTarget(_targetTemp - _temperatureChangeStep);
  }

  void _updateTarget(double value) {
    setState(() => _targetTemp = value.clamp(0, 100));

    // Reset the timer if it's already running
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _heaterControllerStateStore.changeTargetTemperature(_targetTemp);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return SliderContainer(
      direction: AxisDirection.up,
      onChanged: _updateTarget,
      step: 1,
      range: RangeValues(0, 100),
      value: _targetTemp,
      child: Column(
        children: [
          Spacer(),
          Row(
            children: [
              Spacer(),
              Observer(
                builder: (context) {
                  double? storeTargetTemp = _heaterControllerStateStore.targetTemperature;
                  double? lastRequestedTarget = _heaterControllerStateStore.requestedTemperature;

                  String text = storeTargetTemp?.toStringAsFixed(1) ?? "N/A";

                  bool showLabel =
                      _targetTemp != lastRequestedTarget ||
                      (lastRequestedTarget != null && lastRequestedTarget != storeTargetTemp);

                  String badgeTexts = _targetTemp.toStringAsFixed(0);
                  return Badge(
                    alignment: Alignment.topLeft,
                    offset: const Offset(-16, 0),
                    isLabelVisible: showLabel,
                    label: Text(badgeTexts),
                    child: Text(
                      text,
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.changeWeight(FontWeight.w800),
                    ),
                  );
                },
              ),
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
                  localizations.generalTargetTemperature,
                  style: TextTheme.of(context).labelLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.increaseNotifier?.removeListener(increaseTemperature);
    widget.decreaseNotifier?.removeListener(decreaseTemperature);

    _debounce?.cancel();

    _temperatureTargetReaction.call();
    super.dispose();
  }
}

class _PidAutotuneContent extends StatelessWidget {
  const _PidAutotuneContent();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Autotuning..."));
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
          child: Text("Ramybės būsena", style: TextTheme.of(context).labelLarge),
        ),
      ],
    );
  }
}

class _HeaterModeSelect extends StatelessWidget {
  final HeaterStatus? currentStatus;
  final void Function(HeaterMode)? onSelected;

  const _HeaterModeSelect({this.onSelected, this.currentStatus});

  IconData statusToIcon(HeaterStatus? value) => switch (value) {
    HeaterStatus.heatingManual => MdiIcons.gasBurner,
    HeaterStatus.heatingPid => MdiIcons.thermometerAuto,
    HeaterStatus.idle => MdiIcons.sleep,
    HeaterStatus.error => MdiIcons.kettleAlertOutline,
    HeaterStatus.unknown => MdiIcons.helpCircleOutline,
    HeaterStatus.autotunePid => MdiIcons.progressWrench,
    null => MdiIcons.dotsHorizontal,
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
      itemBuilder:
          (BuildContext context) =>
              [HeaterMode.idle, HeaterMode.heatingPid, HeaterMode.heatingManual]
                  .map(
                    (v) => PopupMenuItem<HeaterMode>(
                      value: v,
                      child: Row(
                        children: [
                          Icon(statusToIcon(v.toHeaterStatus())),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                          Text(v.jsonValue),
                        ],
                      ),
                    ),
                  )
                  .toList(),
    );
  }
}

class ButtonTapNotifier with ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
