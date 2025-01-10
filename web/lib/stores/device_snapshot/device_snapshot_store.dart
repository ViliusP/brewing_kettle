import 'dart:developer';

import 'package:brew_kettle_dashboard/core/data/models/store/ws_listener.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/outbound_message.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:mobx/mobx.dart';

part 'device_snapshot_store.g.dart';

// ignore: library_private_types_in_public_api
class DeviceSnapshotStore = _DeviceSnapshotStore with _$DeviceSnapshotStore;

abstract class _DeviceSnapshotStore with Store {
  final WebSocketConnectionStore _webSocketConnectionStore;

  _DeviceSnapshotStore({
    required WebSocketConnectionStore webSocketConnectionStore,
  }) : _webSocketConnectionStore = webSocketConnectionStore {
    _webSocketConnectionStore.subscribe(StoreWebSocketListener(
      _onData,
      InboundMessageType.snapshot,
      "DeviceSnapshotStore",
    ));
  }

  @observable
  DeviceSnapshot? snapshot;

  @computed
  bool get waitingResponse => _waitingResponse;

  @observable
  bool _waitingResponse = false;

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
    if (message.payload is DeviceSnapshot) {
      log("DEVICE_SNAPSHOT_STORE got message");
      snapshot = (message.payload as DeviceSnapshot);
    }
  }

  void dispose() async {}
}
