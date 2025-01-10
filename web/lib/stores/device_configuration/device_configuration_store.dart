import 'dart:developer';

import 'package:brew_kettle_dashboard/core/data/models/store/ws_listener.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/outbound_message.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:mobx/mobx.dart';

part 'device_configuration_store.g.dart';

// ignore: library_private_types_in_public_api
class DeviceConfigurationStore = _DeviceConfigurationStore
    with _$DeviceConfigurationStore;

abstract class _DeviceConfigurationStore with Store {
  final WebSocketConnectionStore _webSocketConnectionStore;

  _DeviceConfigurationStore({
    required WebSocketConnectionStore webSocketConnectionStore,
  }) : _webSocketConnectionStore = webSocketConnectionStore {
    _webSocketConnectionStore.subscribe(StoreWebSocketListener(
      _onData,
      InboundMessageType.configuration,
      "DeviceConfigurationStore",
    ));
  }

  @observable
  DeviceConfiguration? configuration;

  @computed
  bool get waitingResponse => _waitingResponse;

  @observable
  bool _waitingResponse = false;

  @action
  void request() {
    if (_webSocketConnectionStore.connectedTo != null) {
      var message = WsMessageComposer.requestConfiguration();
      _webSocketConnectionStore.message(message);
    } else {
      log("Cannot send configuration request because there is no online channell");
    }
  }

  @action
  void _onData(WsInboundMessage message) {
    if (message.payload is DeviceConfiguration) {
      log("DEVICE_CONFIGURATION_STORE got message");
      configuration = (message.payload as DeviceConfiguration);
    }
  }

  void dispose() async {}
}
