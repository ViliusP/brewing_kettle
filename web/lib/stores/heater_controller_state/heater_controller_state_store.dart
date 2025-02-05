import 'dart:developer';

import 'package:brew_kettle_dashboard/core/data/models/store/ws_listener.dart';
import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/outbound_message.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:mobx/mobx.dart';

part 'heater_controller_state_store.g.dart';

// ignore: library_private_types_in_public_api
class HeaterControllerStateStore = _HeaterControllerStateStore
    with _$HeaterControllerStateStore;

abstract class _HeaterControllerStateStore with Store {
  final WebSocketConnectionStore _webSocketConnectionStore;

  _HeaterControllerStateStore({
    required WebSocketConnectionStore webSocketConnectionStore,
  }) : _webSocketConnectionStore = webSocketConnectionStore {
    _webSocketConnectionStore.subscribe(StoreWebSocketListener(
      _onData,
      InboundMessageType.heaterControllerState,
      "HeaterControllerStateStore",
    ));
  }

  @observable
  HeaterControllerState? _state;

  @computed
  List<TimeseriesViewEntry> get temperatureHistory =>
      TimeSeries.from(_temperatureHistory.toList()).aggregate(
        type: AggregationType.mean,
        interval: AggregationInterval.seconds(10),
      );

  @observable
  // ignore: prefer_final_fields
  ObservableList<TimeSeriesEntry> _temperatureHistory = ObservableList.of([]);

  @computed
  double? get currentTemperature => _state?.currentTemperature;

  @computed
  HeaterStatus? get status => _state?.status;

  // -----------------------
  // TARGET TEMPERATURE STATE
  // -----------------------

  @computed
  double? get targetTemperature => _state?.targetTemperature;

  @computed
  double? get lastRequestedTemperature => _lastRequestedTemperature;

  @observable
  double? _lastRequestedTemperature;

  // -----------------------
  // POWER STATE
  // -----------------------

  @computed
  double? get power => _state?.power;

  @computed
  double? get lastRequestedPower => _lastRequestedPower;

  @observable
  double? _lastRequestedPower;

  // -----------------------
  // ACTIONS
  // -----------------------

  @action
  void changeTargetTemperature(double value) {
    if (_webSocketConnectionStore.connectedTo == null) {
      log("Cannot send set target temperature request because there is no online channell");

      return;
    }
    var message = WsMessageComposer.requestStateChangeMessage(
      OutboundMessageType.temperatureSet,
      value,
    );
    // _lastRequestID = message.id;
    _lastRequestedTemperature = value;
    _webSocketConnectionStore.message(message.jsonString);
  }

  @action
  void changePower(double value) {
    if (_webSocketConnectionStore.connectedTo == null) {
      log("Cannot send set power request because there is no online channell");

      return;
    }
    var message = WsMessageComposer.requestStateChangeMessage(
      OutboundMessageType.powerSet,
      value,
    );
    _lastRequestedPower = value;
    _webSocketConnectionStore.message(message.jsonString);
  }

  @action
  void changeMode(HeaterMode value) {
    if (_webSocketConnectionStore.connectedTo == null) {
      log("Cannot send snapshot request because there is no online channell");

      return;
    }
    var message = WsMessageComposer.requestStateChangeMessage(
      OutboundMessageType.heaterModeSet,
      value.jsonValue,
    );

    _webSocketConnectionStore.message(message.jsonString);
  }

  @action
  void _onData(WsInboundMessage message) {
    if (message.payload is HeaterControllerState &&
        message.type == InboundMessageType.heaterControllerState) {
      var heaterState = (message.payload as HeaterControllerState);
      _state = heaterState;
      _temperatureHistory.add(
        TimeSeriesEntry(
          DateTime.fromMillisecondsSinceEpoch(heaterState.timestamp * 1000),
          heaterState.currentTemperature,
        ),
      );
    }
  }

  void dispose() async {}
}
