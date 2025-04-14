import 'dart:async';

import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:brew_kettle_dashboard/ui/common/idle_circles/idle_circles.dart';
import 'package:brew_kettle_dashboard/ui/common/slider_container/slider_container.dart';
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
              child: _HeaterControlContent(
                increaseTapNotifier: _increaseTapNotifier,
                decreaseTapNotifier: _decreaseTapNotifier,
              ),
            ),
            VerticalDivider(
              width: 0,
              color: colorScheme.outlineVariant.withAlpha(255 ~/ 2),
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _HeaterControls(
                increaseTapNotifier: _increaseTapNotifier,
                decreaseTapNotifier: _decreaseTapNotifier,
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

class _HeaterControls extends StatelessWidget {
  _HeaterControls({
    required ButtonTapNotifier increaseTapNotifier,
    required ButtonTapNotifier decreaseTapNotifier,
  }) : _increaseTapNotifier = increaseTapNotifier,
       _decreaseTapNotifier = decreaseTapNotifier;

  final ButtonTapNotifier _increaseTapNotifier;
  final ButtonTapNotifier _decreaseTapNotifier;
  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Observer(
      builder: (context) {
        final controllerStatus = _heaterControllerStateStore.status;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: switch (controllerStatus) {
                HeaterStatus.heatingManual => localizations.heaterControlIncreasePower,
                HeaterStatus.heatingPid => localizations.heaterControlIncreaseTemperature,
                _ => null,
              },
              onPressed: switch (controllerStatus) {
                // HeaterStatus.heatingPid when !_heaterControllerStateStore.isModeChanging=> _increaseTapNotifier.notify,
                // HeaterStatus.heatingManual when !_heaterControllerStateStore.isModeChanging => _increaseTapNotifier.notify,
                HeaterStatus.heatingPid => _increaseTapNotifier.notify,
                HeaterStatus.heatingManual => _increaseTapNotifier.notify,
                _ => null,
              },
              icon: Icon(MdiIcons.arrowUpDropCircleOutline),
              iconSize: 60,
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
            _HeaterModeSelect(
              onSelected: (value) => _heaterControllerStateStore.changeMode(value),
              currentStatus: controllerStatus,
              enabled: switch (controllerStatus) {
                HeaterStatus.idle => true,
                HeaterStatus.heatingPid => true,
                HeaterStatus.heatingManual => true,
                HeaterStatus.error => true,
                HeaterStatus.unknown => true,
                HeaterStatus.autotunePid => false,
                HeaterStatus.waitingConfiguration => false,
                null => false,
              },
            ),
            Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
            IconButton(
              tooltip: switch (controllerStatus) {
                HeaterStatus.heatingManual => localizations.heaterControlDecreasePower,
                HeaterStatus.heatingPid => localizations.heaterControlDecreaseTemperature,
                _ => null,
              },
              onPressed: switch (controllerStatus) {
                HeaterStatus.heatingPid => _decreaseTapNotifier.notify,
                HeaterStatus.heatingManual => _decreaseTapNotifier.notify,
                _ => null,
              },
              icon: Icon(MdiIcons.arrowDownDropCircleOutline),
              iconSize: 60,
            ),
          ],
        );
      },
    );
  }
}

class _HeaterControlContent extends StatelessWidget {
  _HeaterControlContent({
    required ButtonTapNotifier increaseTapNotifier,
    required ButtonTapNotifier decreaseTapNotifier,
  }) : _increaseTapNotifier = increaseTapNotifier,
       _decreaseTapNotifier = decreaseTapNotifier;

  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  final ButtonTapNotifier _increaseTapNotifier;
  final ButtonTapNotifier _decreaseTapNotifier;

  @override
  Widget build(BuildContext context) {
    return Observer(
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
            HeaterStatus.idle => _IdleStatusContent(),
            HeaterStatus.error => _ErrorStatusContent(),
            HeaterStatus.unknown => _UnknownStatusContent(),
            HeaterStatus.waitingConfiguration => _WaitingConfigurationStatusContent(),
            null => _UnknownStatusContent(),
          },
        );
      },
    );
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
                      ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
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

class _WaitingConfigurationStatusContent extends StatelessWidget {
  const _WaitingConfigurationStatusContent();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Spacer(),
        Row(children: [Spacer(), Icon(MdiIcons.lanPending, size: 54), Spacer()]),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Text(
          localizations.heaterControlCardMessageConfiguring,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                localizations.heaterControlCardLabelConfiguring,
                style: textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnknownStatusContent extends StatelessWidget {
  const _UnknownStatusContent();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Spacer(),
        Row(children: [Spacer(), Icon(MdiIcons.helpRhombus, size: 54), Spacer()]),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Text(
          localizations.heaterControlCardMessageStatusUnknown,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                localizations.heaterControlCardLabelStatusUnknown,
                style: textTheme.labelLarge,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorStatusContent extends StatelessWidget {
  const _ErrorStatusContent();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Spacer(),
        Row(children: [Spacer(), Icon(MdiIcons.alertCircleOutline, size: 54), Spacer()]),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Text(
          localizations.heaterControlCardMessageError,
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(localizations.heaterControlCardLabelError, style: textTheme.labelLarge),
            ),
          ),
        ),
      ],
    );
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
                      ).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800),
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
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Center(child: Text(localizations.heaterControlCardLabelAutotune));
  }
}

class _IdleStatusContent extends StatelessWidget {
  const _IdleStatusContent();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Expanded(child: AnimatedIdleCircles()),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            localizations.heaterControlCardLabelIdle,
            style: TextTheme.of(context).labelLarge,
          ),
        ),
      ],
    );
  }
}

class _HeaterModeSelect extends StatelessWidget {
  final HeaterStatus? currentStatus;
  final void Function(HeaterMode)? onSelected;
  final bool enabled;

  const _HeaterModeSelect({this.onSelected, this.currentStatus, this.enabled = true});

  IconData statusToIcon(HeaterStatus? value) => switch (value) {
    HeaterStatus.heatingManual => MdiIcons.gasBurner,
    HeaterStatus.heatingPid => MdiIcons.thermometerAuto,
    HeaterStatus.idle => MdiIcons.sleep,
    HeaterStatus.error => MdiIcons.kettleAlertOutline,
    HeaterStatus.unknown => MdiIcons.helpCircleOutline,
    HeaterStatus.autotunePid => MdiIcons.progressWrench,
    HeaterStatus.waitingConfiguration => MdiIcons.lanPending,
    null => MdiIcons.dotsHorizontal,
  };

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    HeaterMode? initialValue;
    if (currentStatus != null) {
      initialValue = HeaterMode.fromHeaterStatus(currentStatus!);
    }

    return PopupMenuButton<HeaterMode>(
      iconSize: 28,
      padding: EdgeInsets.all(8),
      tooltip: localizations.heaterControlSelectButtonTooltip(initialValue?.jsonValue ?? "null"),
      icon: Icon(statusToIcon(currentStatus)),
      initialValue: initialValue,
      onSelected: onSelected,
      enabled: enabled,
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
                          Text(localizations.heaterControlSelectButtonLabel(v.jsonValue)),
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
