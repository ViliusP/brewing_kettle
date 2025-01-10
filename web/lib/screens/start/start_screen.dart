import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/stores/device_configuration/device_configuration_store.dart';
import 'package:brew_kettle_dashboard/stores/device_snapshot/device_snapshot_store.dart';
import 'package:brew_kettle_dashboard/stores/network_scanner/network_scanner_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyHomePage(title: "ABC");
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ------- STORES -------
  final NetworkScannerStore _networkScannerStore = getIt<NetworkScannerStore>();
  final WebSocketConnectionStore _wsConnectionStore =
      getIt<WebSocketConnectionStore>();

  final DeviceConfigurationStore _deviceConfigurationStore =
      getIt<DeviceConfigurationStore>();

  final DeviceSnapshotStore _deviceSnapshotStore = getIt<DeviceSnapshotStore>();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Observer(builder: (context) {
              return Text(
                "Scan state: ${_networkScannerStore.state}",
              );
            }),
            Observer(builder: (context) {
              final maybeFirstRecord = _networkScannerStore.records.firstOrNull;
              if (maybeFirstRecord == null) {
                return Text("No records found");
              }
              return Text(
                "${maybeFirstRecord.hostname}:${maybeFirstRecord.port}\n${maybeFirstRecord.ip}:${maybeFirstRecord.port}",
              );
            }),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              child: const Text('Connect'),
              onPressed: () {
                final maybeFirstRecord =
                    _networkScannerStore.records.firstOrNull;
                if (maybeFirstRecord == null) {
                  return;
                }
                String address =
                    "ws://${maybeFirstRecord.hostname}:${maybeFirstRecord.port}/ws";
                _wsConnectionStore.connect(address);
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              child: const Text('Send'),
              onPressed: () {
                _wsConnectionStore.message("Hello There");
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              child: const Text('Send'),
              onPressed: () {
                _deviceConfigurationStore.request();
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5);
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
              child: const Text('Send'),
              onPressed: () {
                _deviceSnapshotStore.request();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        tooltip: 'Send message',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _startScan() {
    _networkScannerStore.start();
  }

  @override
  void dispose() {
    _wsConnectionStore.close();
    _controller.dispose();
    super.dispose();
  }
}
