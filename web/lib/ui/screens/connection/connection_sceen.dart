import 'package:brew_kettle_dashboard/core/service_locator.dart';

import 'package:brew_kettle_dashboard/stores/network_scanner/network_scanner_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/screens/connection/suggestion_row.dart';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  // ------- STORES -------
  final NetworkScannerStore _networkScannerStore = getIt<NetworkScannerStore>();
  final WebSocketConnectionStore _wsConnectionStore =
      getIt<WebSocketConnectionStore>();

  final TextEditingController _ipFormController = TextEditingController();

  void tryConnect() {
    final maybeFirstRecord = _networkScannerStore.records.firstOrNull;
    if (maybeFirstRecord == null) {
      return;
    }
    String address =
        "ws://${maybeFirstRecord.hostname}:${maybeFirstRecord.port}/ws";
    _wsConnectionStore.connect(address);
  }

  int chips = 5;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
          vertical: 8.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SuggestionsRow(
              trailing: ScanDevicesChip(),
              children: List.generate(
                chips,
                (index) =>
                    IpSuggestionChip(text: "IP: $index.$index.$index.$index"),
              ),
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 12)),
            TextFormField(
              controller: _ipFormController,
              style: TextStyle(
                fontSize: 24,
              ),
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                labelStyle: TextStyle(fontSize: 20),
                labelText: "Device IP address",
                helperText: "For example: \"ws://0.0.0.0:80/ws\"",
                filled: true,
                helperStyle: TextStyle(fontSize: 14),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(
                    MdiIcons.ipOutline,
                    size: 28,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                minimumSize: Size(360, 60),
                elevation: 2,
              ),
              onPressed: () => tryConnect(),
              icon: Icon(MdiIcons.connection, size: 20),
              label: const Text('Connect', style: TextStyle(fontSize: 20)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                minimumSize: Size(360, 60),
                elevation: 2,
              ),
              onPressed: () {
                setState(() {
                  chips++;
                });
              },
              icon: Icon(MdiIcons.connection, size: 20),
              label: const Text('Add', style: TextStyle(fontSize: 20)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                minimumSize: Size(360, 60),
                elevation: 2,
              ),
              onPressed: () {
                if (chips == 0) return;

                setState(() {
                  chips--;
                });
              },
              icon: Icon(MdiIcons.connection, size: 20),
              label: const Text('Remove', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }

  void _startScan() {
    _networkScannerStore.start();
  }

  @override
  void dispose() {
    _ipFormController.dispose();
    super.dispose();
  }
}
