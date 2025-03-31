import 'dart:developer';

import 'package:brew_kettle_dashboard/core/data/models/store/ws_listener.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/outbound_message.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:mobx/mobx.dart';

part 'pid_store.g.dart';

// ignore: library_private_types_in_public_api
class PidStore = _PidStore with _$PidStore;

abstract class _PidStore with Store {
  final WebSocketConnectionStore _webSocketConnectionStore;

  _PidStore({required WebSocketConnectionStore webSocketConnectionStore})
    : _webSocketConnectionStore = webSocketConnectionStore {
    _webSocketConnectionStore.subscribe(
      StoreWebSocketListener(_onData, InboundMessageType.heaterControllerState, "PidStore"),
    );
  }

  @observable
  PidConstants? _pidConstants;

  @computed
  double? get proportional => _pidConstants?.proportional;

  @computed
  double? get integral => _pidConstants?.integral;

  @computed
  double? get derivative => _pidConstants?.derivative;

  @observable
  bool _isConstantsChanging = false;

  @computed
  bool get isConstantsChanging => _isConstantsChanging;

  // -----------------------
  // ACTIONS
  // -----------------------
  @action
  void changeConstants({
    required double proportional,
    required double integral,
    required double derivative,
  }) {
    if (_webSocketConnectionStore.connectedTo == null) {
      log("Cannot send snapshot request because there is no online channell");

      return;
    }
    _isConstantsChanging = true;

    var message = WsMessageComposer.changePidConstantsMessage(
      proportional: proportional,
      integral: integral,
      derivative: derivative,
    );

    _webSocketConnectionStore.message(message.jsonString);
  }

  @action
  void _onData(WsInboundMessage message) {
    if (message.payload is PidConstants && message.type == InboundMessageType.pidConstants) {
      var pidConstants = (message.payload as PidConstants);
      _isConstantsChanging = false;
      _pidConstants = pidConstants;
    }
  }
}
