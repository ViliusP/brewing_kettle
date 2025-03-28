import 'package:brew_kettle_dashboard/core/service_locator.dart';

import 'package:brew_kettle_dashboard/stores/network_scanner/network_scanner_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/screens/connection/suggestion_row.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  // ------- STORES -------
  final NetworkScannerStore _networkScannerStore = getIt<NetworkScannerStore>();
  final WebSocketConnectionStore _wsConnectionStore = getIt<WebSocketConnectionStore>();

  final TextEditingController _ipFormController = TextEditingController();

  List<bool> _selectedChips = [];

  ReactionDisposer? _networkDevicesReactionDispose;

  @override
  void initState() {
    if (!kIsWeb) {
      _networkDevicesReactionDispose = reaction(
        (_) => _networkScannerStore.records,
        (_) => setSelectedChip(),
        fireImmediately: true,
      );
      _ipFormController.addListener(() => setSelectedChip());

      _networkScannerStore.start();
    }
    super.initState();
  }

  void setSelectedChip() {
    List<RecordMDNS> records = _networkScannerStore.records;
    List<bool> newChipsState = [];

    for (var record in records) {
      String address = "ws://${record.hostname}:${record.port}/ws";
      newChipsState.add(address == _ipFormController.text);
    }
    if (!listEquals(_selectedChips, newChipsState)) {
      setState(() => _selectedChips = newChipsState);
    }
  }

  void tryConnect() {
    final address = _ipFormController.text;
    if (address.isEmpty) {
      return;
    }
    final uriAddress = Uri.tryParse(address);

    if (uriAddress == null) {
      return;
    }

    _wsConnectionStore.connect(uriAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!kIsWeb)
              SuggestionsRow(
                trailing: Observer(
                  builder: (_) {
                    onPressed() => _networkScannerStore.start();
                    bool loading = _networkScannerStore.state == NetworkScannerState.scanning;

                    return ScanDevicesChip(onPressed: loading ? null : onPressed, loading: loading);
                  },
                ),
                child: Observer(
                  builder: (context) {
                    int length = _networkScannerStore.records.length;
                    return Row(
                      spacing: 6,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(length, (i) {
                        var record = _networkScannerStore.records[i];
                        var port = record.port;

                        String addressToShow = "${record.hostname}:$port";
                        String address = "ws://$addressToShow/ws";

                        String tooltip = "${record.internetAddress.address}:$port";

                        return IpSuggestionChip(
                          onSelected: (selected) {
                            if (selected) {
                              _ipFormController.text = address;
                            } else {
                              _ipFormController.text = "";
                            }
                          },
                          selected: _selectedChips[i],
                          tooltip: tooltip,
                          text: addressToShow,
                        );
                      }),
                    );
                  },
                ),
              ),
            if (!kIsWeb) Padding(padding: EdgeInsets.symmetric(vertical: 12)),
            TextFormField(
              controller: _ipFormController,
              style: TextStyle(fontSize: 24),
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                labelStyle: TextStyle(fontSize: 20),
                labelText: "Device IP address",
                helperText: "For example: \"ws://0.0.0.0:80/ws\"",
                filled: true,
                helperStyle: TextStyle(fontSize: 14),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  child: Icon(MdiIcons.ipOutline, size: 28),
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _networkDevicesReactionDispose?.call();
    _ipFormController.dispose();
    super.dispose();
  }
}
