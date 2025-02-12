import 'package:brew_kettle_dashboard/ui/screens/devices/heater_controller_info_card.dart';
import 'package:brew_kettle_dashboard/ui/screens/devices/communicator_controller_info_card.dart';
import 'package:flutter/material.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: SingleChildScrollView(
          primary: true,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 960),
              child: LayoutBuilder(builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(child: CommnuicatorControllerInfoCard()),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 6)),
                      Expanded(child: HeaterControllerInfoCard()),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
