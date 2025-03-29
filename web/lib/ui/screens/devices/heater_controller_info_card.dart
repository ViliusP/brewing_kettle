import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/device_info/system_info_store.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_controller_state_store.dart';
import 'package:flutter/material.dart';

class HeaterControllerInfoCard extends StatelessWidget {
  HeaterControllerInfoCard({super.key});

  final SystemInfoStore _deviceInfoStore = getIt<SystemInfoStore>();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final TextTheme textTheme = TextTheme.of(context);
    final DeviceInfo? info = _deviceInfoStore.info?.heater;
    final DeviceHardwareInfo? hardware = info?.hardware;
    final DeviceSoftwareInfo? software = info?.software;

    return SelectableRegion(
      focusNode: _focusNode,
      selectionControls: materialTextSelectionControls,
      child: Column(
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
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          _PidSection(),
        ],
      ),
    );
  }
}

class _PidSection extends StatelessWidget {
  final HeaterControllerStateStore _heaterControllerStateStore =
      getIt<HeaterControllerStateStore>();

  _PidSection();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: localizations.devicesPidProportionalGain,
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: localizations.devicesPidIntegralGain,
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            // errorText: "Error text",
            labelText: localizations.devicesPidDerivativeGain,
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        OutlinedButton(
          onPressed: () {
            print("Not implemented");
          },
          child: Text("Pakeist"),
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
    );
  }
}
