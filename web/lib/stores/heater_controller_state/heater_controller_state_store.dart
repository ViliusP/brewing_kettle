import 'dart:collection';
import 'dart:developer';

import 'package:brew_kettle_dashboard/core/data/models/store/ws_listener.dart';
import 'package:brew_kettle_dashboard/core/data/models/timeseries/heater_session_statistics.dart';
import 'package:brew_kettle_dashboard/core/data/models/timeseries/timeseries.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/outbound_message.dart';
import 'package:brew_kettle_dashboard/stores/heater_controller_state/heater_state_data_values.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:mobx/mobx.dart';

part 'heater_controller_state_store.g.dart';

// ignore: library_private_types_in_public_api
class HeaterControllerStateStore = _HeaterControllerStateStore with _$HeaterControllerStateStore;

abstract class _HeaterControllerStateStore with Store {
  final WebSocketConnectionStore _webSocketConnectionStore;

  _HeaterControllerStateStore({required WebSocketConnectionStore webSocketConnectionStore})
    : _webSocketConnectionStore = webSocketConnectionStore {
    _webSocketConnectionStore.subscribe(
      StoreWebSocketListener(
        _onData,
        InboundMessageType.heaterControllerState,
        "HeaterControllerStateStore",
      ),
    );
  }

  @observable
  HeaterControllerState? _state;

  @observable
  bool _isModeChanging = false;

  @computed
  bool get isModeChanging => _isModeChanging;

  @computed
  TimeSeries<HeaterControllerState> get _stateTimeSeries =>
      TimeSeries<HeaterControllerState>.from(_stateHistory, {
        "power": (v) => v.power,
        "current_temperature": (v) => v.currentTemperature,
        "target_temperature": (v) => v.targetTemperature,
      });

  @computed
  List<TimeSeriesViewEntry> get stateHistory => _stateTimeSeries
      .takeLastByDuration(_dataDuration)
      .aggregate(
        defaultType: defaultAggregationMethod,
        interval: _aggregationInterval,
        methodsByField: _aggregationMethodsByField.map((k, v) => MapEntry(k.key, v)),
      );

  @computed
  HeaterSessionStatistics get sessionStatistics {
    return HeaterSessionStatistics.fromTimeseries(_stateTimeSeries);
  }

  // -----------------------
  // AGGREGATION OPTIONS
  // -----------------------

  /// The duration over which data is filtered.
  /// This interval determines the time span of data to include,
  /// counted backward from the latest data point.
  @observable
  Duration _dataDuration = HeaterStateHistoryValues.defaultDataDuration;

  /// The duration over which data is aggregated.
  /// This interval determines the time span of data to include,
  /// counted backward from the latest data point.
  @computed
  Duration get dataDuration => _dataDuration;

  @observable
  AggregationInterval _aggregationInterval = HeaterStateHistoryValues.defaultAggregationInterval;

  @computed
  AggregationInterval get aggregationInterval => _aggregationInterval;

  @observable
  AggregationMethod _defaultAggregationMethod = AggregationMethod.mean;

  @computed
  AggregationMethod get defaultAggregationMethod => _defaultAggregationMethod;

  final ObservableMap<HeaterControllerStateField, AggregationMethod> _aggregationMethodsByField =
      ObservableMap.of(const {
        HeaterControllerStateField.power: AggregationMethod.last,
        HeaterControllerStateField.targetTemperature: AggregationMethod.last,
      });

  @computed
  UnmodifiableMapView<HeaterControllerStateField, AggregationMethod>
  get aggregationMethodsByField => UnmodifiableMapView(_aggregationMethodsByField);

  // -----------------------
  // HEATER STATE
  // -----------------------
  @observable
  // ignore: prefer_final_fields
  ObservableList<TimeSeriesEntry<HeaterControllerState>> _stateHistory = ObservableList.of([]);

  @computed
  double? get currentTemperature => _state?.currentTemperature;

  // -----------------------
  // STATUS STATE
  // -----------------------
  @computed
  HeaterStatus? get status => _state?.status;

  // -----------------------
  // TARGET TEMPERATURE STATE
  // -----------------------
  @computed
  double? get targetTemperature => _state?.targetTemperature;

  @computed
  double? get requestedTemperature => _requestedTemperature;

  @observable
  double? _requestedTemperature;

  // -----------------------
  // POWER STATE
  // -----------------------
  @computed
  double? get power => _state?.power;

  @computed
  double? get requestedPower => _requestedPower;

  @observable
  double? _requestedPower;

  // -----------------------
  // ACTIONS
  // -----------------------
  @action
  void setTargetTemperature(double value) {
    if (_webSocketConnectionStore.connectedTo == null) {
      log("Cannot send set target temperature request because there is no online channell");

      return;
    }

    var message = WsMessageComposer.requestStateChangeMessage(
      OutboundMessageType.temperatureSet,
      value,
    );
    // _lastRequestID = message.id;
    _requestedTemperature = value;
    _webSocketConnectionStore.message(message.jsonString);
  }

  @action
  void setPower(double value) {
    if (_webSocketConnectionStore.connectedTo == null) {
      log("Cannot send set power request because there is no online channell");

      return;
    }
    var message = WsMessageComposer.requestStateChangeMessage(OutboundMessageType.powerSet, value);
    _requestedPower = value;
    _webSocketConnectionStore.message(message.jsonString);
  }

  @action
  void setMode(HeaterMode value) {
    if (_webSocketConnectionStore.connectedTo == null) {
      log("Cannot send snapshot request because there is no online channell");

      return;
    }
    if (value.toHeaterStatus() == status) {
      return;
    }
    _isModeChanging = true;
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
      if (heaterState.status != _state?.status) {
        _isModeChanging = false;
      }
      _state = heaterState;

      _stateHistory.add(
        TimeSeriesEntry<HeaterControllerState>(
          DateTime.fromMillisecondsSinceEpoch(heaterState.timestamp * 1000),
          heaterState,
        ),
      );
    }
  }

  /// Null means default
  @action
  void setFieldAggregationMethod(HeaterControllerStateField field, AggregationMethod? method) {
    if (method == null && _aggregationMethodsByField.containsKey(field)) {
      _aggregationMethodsByField.remove(field);
      return;
    }

    if (method == null) return;

    _aggregationMethodsByField[field] = method;
  }

  @action
  void setDefaultAggregationMethod(AggregationMethod method) {
    _defaultAggregationMethod = method;
  }

  @action
  void setAggregationInterval(int seconds) {
    _aggregationInterval = AggregationInterval.seconds(seconds);
  }

  @action
  void setDataInterval(Duration duration) {
    _dataDuration = duration;
  }

  void dispose() async {}
}

enum HeaterControllerStateField {
  power("power"),
  currentTemperature("current_temperature"),
  targetTemperature("target_temperature");

  const HeaterControllerStateField(this.key);

  final String key;
}
