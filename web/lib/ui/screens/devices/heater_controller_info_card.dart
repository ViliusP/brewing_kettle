import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/device_info/system_info_store.dart';
import 'package:brew_kettle_dashboard/stores/pid/pid_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:mobx/mobx.dart';

class HeaterControllerInfoCard extends StatelessWidget {
  HeaterControllerInfoCard({super.key});

  final SystemInfoStore _deviceInfoStore = getIt<SystemInfoStore>();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = TextTheme.of(context);
    final DeviceInfo? info = _deviceInfoStore.info?.heater;
    final DeviceHardwareInfo? hardware = info?.hardware;
    final DeviceSoftwareInfo? software = info?.software;

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(localizations.devicesHeaterController, style: textTheme.titleLarge),
        SelectableRegion(
          selectionControls: materialTextSelectionControls,
          child: Column(
            children: [
              Text("${hardware?.chip}", style: textTheme.bodyLarge),
              Padding(padding: EdgeInsets.symmetric(vertical: 2)),
              Text(
                "${localizations.generalVersion} ${software?.version}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "${localizations.devicesSecureVersion} ${software?.secureVersion}",
                style: textTheme.bodyMedium,
              ),
              Text(
                "${localizations.devicesCompileTime} ${software?.compileTime}",
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Divider(),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        Text(localizations.devicesPid, style: textTheme.titleLarge),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        _PidSection(),
      ],
    );
  }
}

class _PidSection extends StatefulWidget {
  const _PidSection();

  @override
  State<_PidSection> createState() => _PidSectionState();
}

class _PidSectionState extends State<_PidSection> {
  final PidStore pidStore = getIt<PidStore>();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController pidKpController = TextEditingController();
  final TextEditingController pidKiController = TextEditingController();
  final TextEditingController pidKdController = TextEditingController();

  bool showResetKpButton = false;
  bool showResetKiButton = false;
  bool showResetKdButton = false;

  late final storeKpReactionDispose = reaction((_) => pidStore.proportional, (val) {
    bool lastShowResetKpButton = showResetKpButton;
    showResetKpButton = pidStore.proportional.toString() != pidKpController.text;
    if (lastShowResetKpButton != showResetKpButton) setState(() {});
  });
  late final storeKiReactionDispose = reaction((_) => pidStore.integral, (val) {
    bool lastShowResetKiButton = showResetKiButton;
    showResetKiButton = pidStore.integral.toString() != pidKiController.text;
    if (lastShowResetKiButton != showResetKiButton) setState(() {});
  });
  late final storeKdReactionDispose = reaction((_) => pidStore.derivative, (val) {
    bool lastShowResetKdButton = showResetKdButton;
    showResetKdButton = pidStore.derivative.toString() != pidKdController.text;
    if (lastShowResetKdButton != showResetKdButton) setState(() {});
  });

  @override
  void initState() {
    // Proportional
    pidKpController.addListener(() {
      bool lastShowResetKpButton = showResetKpButton;
      String storeTextValue = pidStore.integral.toString();
      if (pidStore.proportional == null) {
        storeTextValue = "";
      }
      showResetKpButton = storeTextValue != pidKpController.text;
      if (lastShowResetKpButton != showResetKpButton) {
        setState(() {});
      }
    });
    // Integral
    pidKiController.addListener(() {
      bool lastShowResetKiButton = showResetKiButton;
      String storeTextValue = pidStore.integral.toString();
      if (pidStore.integral == null) {
        storeTextValue = "";
      }
      showResetKiButton = storeTextValue != pidKiController.text;
      if (lastShowResetKiButton != showResetKiButton) {
        setState(() {});
      }
    });
    // Derivative
    pidKdController.addListener(() {
      bool lastShowResetKdButton = showResetKdButton;
      String storeTextValue = pidStore.derivative.toString();
      if (pidStore.derivative == null) {
        storeTextValue = "";
      }
      showResetKdButton = storeTextValue != pidKdController.text;
      if (lastShowResetKdButton != showResetKdButton) {
        setState(() {});
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (pidStore.proportional != null) {
        pidKpController.value = TextEditingValue(text: pidStore.proportional.toString());
      }
      if (pidStore.integral != null) {
        pidKiController.value = TextEditingValue(text: pidStore.integral.toString());
      }
      if (pidStore.derivative != null) {
        pidKdController.value = TextEditingValue(text: pidStore.derivative.toString());
      }
    });
    super.initState();
  }

  String? pidConstantsValidator(String? value, double maxValue) {
    if (value == null || value.isEmpty) {
      return "Field required (TODO localize)";
    }
    double? maybeNumber = double.tryParse(value);
    if (maybeNumber == null) {
      return "Field must be number (TODO localize)";
    }
    if (maybeNumber < 0) {
      return "Field must be positive (TODO localize)";
    }
    if (maybeNumber > maxValue) {
      return "Field must be less than $maxValue (TODO localize)";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUnfocus,
      child: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.number,
            controller: pidKpController,
            validator: (value) => pidConstantsValidator(value, AppConstants.maxProportional),
            decoration: InputDecoration(
              helperText:
                  "Value must be lower than ${AppConstants.maxProportional} (TODO localize)",
              border: OutlineInputBorder(),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: AnimatedSwitcher(
                  duration: Durations.short2,
                  child:
                      showResetKpButton
                          ? IconButton(
                            key: ValueKey<String>("icon_button_1"),
                            onPressed: () {
                              pidKpController.value = TextEditingValue(
                                text: pidStore.proportional.toString(),
                              );
                            },
                            icon: Icon(MdiIcons.redoVariant),
                            iconSize: 18,
                          )
                          : SizedBox(key: ValueKey<String>("sized_box_1")),
                ),
              ),
              labelText: localizations.devicesPidProportionalGain,
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: pidKiController,
            validator: (value) => pidConstantsValidator(value, AppConstants.maxIntegral),
            decoration: InputDecoration(
              helperText: "Value must be lower than ${AppConstants.maxIntegral} (TODO localize)",
              border: OutlineInputBorder(),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: AnimatedSwitcher(
                  duration: Durations.short2,
                  child:
                      showResetKiButton
                          ? IconButton(
                            key: ValueKey("icon_button_2"),
                            onPressed: () {
                              pidKiController.value = TextEditingValue(
                                text: pidStore.integral.toString(),
                              );
                            },
                            icon: Icon(MdiIcons.redoVariant),
                            iconSize: 18,
                          )
                          : SizedBox(key: ValueKey("sized_box_2")),
                ),
              ),
              labelText: localizations.devicesPidIntegralGain,
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          TextFormField(
            keyboardType: TextInputType.number,
            controller: pidKdController,
            validator: (value) => pidConstantsValidator(value, AppConstants.maxDerivative),
            decoration: InputDecoration(
              helperText: "Value must be lower than ${AppConstants.maxDerivative} (TODO localize)",
              border: OutlineInputBorder(),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: AnimatedSwitcher(
                  duration: Durations.short2,
                  child:
                      showResetKdButton
                          ? IconButton(
                            key: ValueKey("icon_button_3"),
                            onPressed: () {
                              pidKdController.value = TextEditingValue(
                                text: pidStore.derivative.toString(),
                              );
                            },
                            icon: Icon(MdiIcons.redoVariant),
                            iconSize: 18,
                          )
                          : SizedBox(key: ValueKey("sized_box_3")),
                ),
              ),
              labelText: localizations.devicesPidDerivativeGain,
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          OutlinedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                pidStore.changeConstants(
                  proportional: double.parse(pidKpController.text),
                  integral: double.parse(pidKiController.text),
                  derivative: double.parse(pidKdController.text),
                );
              }
            },
            child: Text(localizations.generalChange),
          ),
          // Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          // TextFormField(
          //   decoration: InputDecoration(border: OutlineInputBorder(), labelText: "Tune duration (s)"),
          // ),
          // OutlinedButton(
          //   onPressed: () => _heaterControllerStateStore.changeMode(HeaterMode.autotunePid),
          //   child: Text("PID autotune"),
          // ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pidKpController.dispose();
    pidKiController.dispose();
    pidKdController.dispose();

    storeKpReactionDispose();
    storeKiReactionDispose();
    storeKdReactionDispose();
    super.dispose();
  }
}
