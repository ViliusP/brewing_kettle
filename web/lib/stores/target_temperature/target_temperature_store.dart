import 'dart:developer';

import 'package:brew_kettle_dashboard/core/data/models/store/ws_listener.dart';
import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/outbound_message.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:mobx/mobx.dart';

part 'target_temperature_store.g.dart';

// ignore: library_private_types_in_public_api
class TargetTemperatureStore = _TargetTemperatureStore
    with _$TargetTemperatureStore;

abstract class _TargetTemperatureStore with Store {
  final WebSocketConnectionStore _webSocketConnectionStore;

  _TargetTemperatureStore({
    required WebSocketConnectionStore webSocketConnectionStore,
  }) : _webSocketConnectionStore = webSocketConnectionStore {
    _webSocketConnectionStore.subscribe(StoreWebSocketListener(
      _onData,
      InboundMessageType.currentTemperature,
      "TargetTemperatureStore",
    ));
  }

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
  double? get targetTemperature => _targetTemperature;

  @observable
  double? _targetTemperature;

  @computed
  double? get lastRequestedTemperature => _lastRequestedTemperature;

  @observable
  double? _lastRequestedTemperature;

  String? _lastRequestID;

  @action
  void changeTargetTemperature(double value) {
    if (_webSocketConnectionStore.connectedTo != null) {
      var message = WsMessageComposer.setValueMessage(
        OutboundMessageType.temperatureSet,
        value,
      );
      _lastRequestID = message.id;
      _lastRequestedTemperature = value;
      _webSocketConnectionStore.message(message.jsonString);
    } else {
      log("Cannot send snapshot request because there is no online channell");
    }
  }

  @action
  void _onData(WsInboundMessage message) {
    if (message.payload is MessageSimpleValue<double> &&
        message.type == InboundMessageType.targetTemperature) {
      var tempMessage = (message.payload as MessageSimpleValue);
      _targetTemperature = tempMessage.value;
      _temperatureHistory.add(
        TimeSeriesEntry(
          DateTime.fromMillisecondsSinceEpoch(tempMessage.timestamp * 1000),
          tempMessage.value,
        ),
      );
    }
  }

  void dispose() async {}
}
