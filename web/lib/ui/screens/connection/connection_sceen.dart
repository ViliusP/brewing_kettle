import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';

import 'package:brew_kettle_dashboard/stores/network_scanner/network_scanner_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:brew_kettle_dashboard/ui/screens/connection/buttons_row.dart';
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
  final NetworkScannerStore networkScannerStore = getIt<NetworkScannerStore>();
  final TextEditingController ipFormController = TextEditingController();

  List<bool> selectedChips = [];

  ReactionDisposer? networkDevicesReactionDispose;

  @override
  void initState() {
    if (!kIsWeb) {
      networkDevicesReactionDispose = reaction(
        (_) => networkScannerStore.records,
        (_) => setSelectedChip(),
        fireImmediately: true,
      );
      ipFormController.addListener(() => setSelectedChip());

      networkScannerStore.start();
    }
    super.initState();
  }

  void setSelectedChip() {
    List<RecordMDNS> records = networkScannerStore.records;
    List<bool> newChipsState = [];

    for (var record in records) {
      String address = "${record.hostname}:${record.port}";
      newChipsState.add(address == ipFormController.text);
    }
    if (!listEquals(selectedChips, newChipsState)) {
      setState(() => selectedChips = newChipsState);
    }
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
            Expanded(child: Align(alignment: Alignment.topRight, child: ButtonsRow())),
            if (!kIsWeb) ...[
              SuggestionsRow(
                trailing: Observer(
                  builder: (_) {
                    onPressed() => networkScannerStore.start();
                    bool loading = networkScannerStore.state == NetworkScannerState.scanning;

                    return ScanDevicesChip(onPressed: loading ? null : onPressed, loading: loading);
                  },
                ),
                child: Observer(
                  builder: (context) {
                    int length = networkScannerStore.records.length;
                    return Row(
                      spacing: 6,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(length, (i) {
                        var record = networkScannerStore.records[i];
                        var port = record.port;

                        String address = "${record.hostname}:$port";

                        String tooltip = "${record.internetAddress.address}:$port";

                        return IpSuggestionChip(
                          onSelected: (selected) {
                            if (selected) {
                              ipFormController.text = address;
                            } else {
                              ipFormController.text = "";
                            }
                          },
                          selected: selectedChips[i],
                          tooltip: tooltip,
                          text: address,
                        );
                      }),
                    );
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12)),
            ],
            _ConnectionForm(ipTextFormController: ipFormController),
            Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    networkDevicesReactionDispose?.call();
    ipFormController.dispose();
    super.dispose();
  }
}

class _ConnectionForm extends StatefulWidget {
  final TextEditingController ipTextFormController;

  const _ConnectionForm({required this.ipTextFormController});

  @override
  State<_ConnectionForm> createState() => __ConnectionFormState();
}

class __ConnectionFormState extends State<_ConnectionForm> {
  static const String exampleIP = "0.0.0.0:80";

  final WebSocketConnectionStore _wsConnectionStore = getIt<WebSocketConnectionStore>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void tryConnect() {
    if (formKey.currentState?.validate() != true) {
      return;
    }

    final address = "ws://${widget.ipTextFormController.text}/ws";
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
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Form(
          key: formKey,
          child: TextFormField(
            controller: widget.ipTextFormController,
            style: TextStyle(fontSize: 24),
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              labelStyle: TextStyle(fontSize: 20),
              labelText: localizations.deviceIpAddressFormLabel,
              helperText: localizations.deviceIpAddressFormHelper(exampleIP),
              filled: true,
              helperStyle: TextStyle(fontSize: 14),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: Icon(MdiIcons.ipOutline, size: 28),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return localizations.deviceIpFormValidationRequired;
              }
              return null;
            },
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        FilledButton.tonalIcon(
          style: FilledButton.styleFrom(minimumSize: Size(360, 60)),
          onPressed: () => tryConnect(),
          icon: Icon(MdiIcons.connection, size: 20),
          label: Text(localizations.connectButtonLabel, style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
