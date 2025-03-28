import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/device_info/system_info_store.dart';
import 'package:brew_kettle_dashboard/ui/screens/devices/heater_controller_info_card.dart';
import 'package:brew_kettle_dashboard/ui/screens/devices/communicator_controller_info_card.dart';
import 'package:flutter/material.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final SystemInfoStore _systemInfoStore = getIt<SystemInfoStore>();

  @override
  void initState() {
    if (_systemInfoStore.info == null && !_systemInfoStore.loading) {
      _systemInfoStore.request();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: SingleChildScrollView(
          primary: true,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1060),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                              child: CommnuicatorControllerInfoCard(),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 8)),
                        Expanded(
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                              child: HeaterControllerInfoCard(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
