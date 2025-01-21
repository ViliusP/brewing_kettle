import 'dart:developer';

import 'package:brew_kettle_dashboard/core/data/models/store/ws_listener.dart';
import 'package:brew_kettle_dashboard/core/data/models/typedefs.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/outbound_message.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:mobx/mobx.dart';

part 'temperature_store.g.dart';

// ignore: library_private_types_in_public_api
class TemperatureStore = _TemperatureStore with _$TemperatureStore;

abstract class _TemperatureStore with Store {
  final WebSocketConnectionStore _webSocketConnectionStore;

  _TemperatureStore({
    required WebSocketConnectionStore webSocketConnectionStore,
  }) : _webSocketConnectionStore = webSocketConnectionStore {
    _webSocketConnectionStore.subscribe(StoreWebSocketListener(
      _onData,
      InboundMessageType.currentTemperature,
      "TemperatureStore",
    ));
  }

  @computed
  List<TempHistoryEntry> get tempHistory => _tempHistory.toList();

  @observable
  // ignore: prefer_final_fields
  ObservableList<TempHistoryEntry> _tempHistory = ObservableList.of([]);

  @computed
  double? get currentTemperature => _currentTemperature;

  @observable
  double? _currentTemperature;

  @action
  void request() {
    if (_webSocketConnectionStore.connectedTo != null) {
      var message = WsMessageComposer.simpleRequest(
        OutboundMessageType.snapshotGet,
      );
      _webSocketConnectionStore.message(message);
    } else {
      log("Cannot send snapshot request because there is no online channell");
    }
  }

  @action
  void _onData(WsInboundMessage message) {
    if (message.payload is MessageSimpleValue<double> &&
        message.type == InboundMessageType.currentTemperature) {
      var tempMessage = (message.payload as MessageSimpleValue);
      _currentTemperature = tempMessage.value;
      int timestamp = tempMessage.timestamp;
      _tempHistory.add((temp: tempMessage.value, timestamp: timestamp));
    }
  }

  void dispose() async {}
}
