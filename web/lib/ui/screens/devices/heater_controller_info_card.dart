import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/device_info/devices_info_store.dart';
import 'package:flutter/material.dart';

class HeaterControllerInfoCard extends StatelessWidget {
  HeaterControllerInfoCard({super.key});

  final DevicesInfoStore _deviceInfoStore = getIt<DevicesInfoStore>();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = TextTheme.of(context);
    DeviceInfo? device = _deviceInfoStore.controllers?.heater;
    DeviceHardwareInfo? hardware = device?.hardware;
    DeviceSoftwareInfo? software = device?.software;

    return SelectableRegion(
      focusNode: _focusNode,
      selectionControls: materialTextSelectionControls,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Virintuvo kontroleris",
            style: textTheme.titleLarge,
          ),
          Text(
            "chip ${hardware?.chip}",
            style: textTheme.bodyMedium,
          ),
          Text(
            "cores ${hardware?.cores}",
            style: textTheme.bodyMedium,
          ),
          Text(
            "Features ${hardware?.features}",
            style: textTheme.bodyMedium,
          ),
          Text(
            "flash size ${hardware?.flash.size} (bytes)",
            style: textTheme.bodyMedium,
          ),
          Text(
            "flash type ${hardware?.flash.type} ",
            style: textTheme.bodyMedium,
          ),
          Text(
            "Silicon revision ${hardware?.siliconRevision}",
            style: textTheme.bodyMedium,
          ),
          Text(
            "Heap size ${hardware?.minimumHeapSize} (bytes)",
            style: textTheme.bodyMedium,
          ),
          Divider(),
          Text(
            "Project name ${software?.projectName}",
            style: textTheme.bodyMedium,
          ),
          Text(
            "Version ${software?.version}",
            style: textTheme.bodyMedium,
          ),
          Text(
            "Secure version ${software?.secureVersion}",
            style: textTheme.bodyMedium,
          ),
          Text(
            "IDF version ${software?.idfVersion}",
            style: textTheme.bodyMedium,
          ),
          Text(
            "Compile time ${software?.compileTime}",
            style: textTheme.bodyMedium,
          ),
          Divider(),
          Divider(),
          Text(
            "PID",
            style: textTheme.titleMedium,
          ),
          _PidSection(),
        ],
      ),
    );
  }
}

class _PidSection extends StatelessWidget {
  const _PidSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Proportional gain",
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Integral gain",
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            // errorText: "Error text",
            labelText: "Derivative gain",
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 8)),
        ElevatedButton(
          onPressed: () {
            print("Not implemented");
          },
          child: Text("Pakeist"),
        )
      ],
    );
  }
}
