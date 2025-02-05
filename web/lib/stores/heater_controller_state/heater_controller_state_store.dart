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
    if (message.payload is HeaterControllerState &&
        message.type == InboundMessageType.heaterControllerState) {
      var tempMessage = (message.payload as HeaterControllerState);
      _currentTemperature = tempMessage.currentTemperature;
      _temperatureHistory.add(
        TimeSeriesEntry(
          DateTime.fromMillisecondsSinceEpoch(tempMessage.timestamp * 1000),
          tempMessage.currentTemperature,
        ),
      );
    }
  }

  void dispose() async {}
}
