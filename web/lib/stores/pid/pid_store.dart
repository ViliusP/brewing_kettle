import 'dart:developer';

import 'package:brew_kettle_dashboard/core/data/models/api/pid_constants.dart';
import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/core/data/repository/repository.dart';
import 'package:brew_kettle_dashboard/stores/exception/exception_store.dart';
import 'package:brew_kettle_dashboard/stores/websocket_connection/websocket_connection_store.dart';
import 'package:mobx/mobx.dart';

part 'pid_store.g.dart';

// ignore: library_private_types_in_public_api
class PidStore = _PidStore with _$PidStore;

abstract class _PidStore with Store {
  // ignore: unused_field
  final WebSocketConnectionStore _webSocketConnectionStore;
  final Repository _repository;
  final ExceptionStore _exceptionStore;

  _PidStore({
    required Repository repository,
    required ExceptionStore exceptionStore,
    required WebSocketConnectionStore webSocketConnectionStore,
  }) : _webSocketConnectionStore = webSocketConnectionStore,
       _repository = repository,
       _exceptionStore = exceptionStore {
    // _webSocketConnectionStore.subscribe(
    //   StoreWebSocketListener(_onData, InboundMessageType.heaterControllerState, "PidStore"),
    // );
  }

  /// The PID constants of the PID controller.
  ///
  /// This is a [_pidConstants] object that contains the proportional, integral, and derivative constants.
  /// The [_pidConstants] are fetched from the server when the store is created.
  /// The [_pidConstants] are updated when the user changes them.
  /// The [_pidConstants] are also updated when the server sends a signal to update constants.
  @observable
  PidConstants? _pidConstants;

  /// The proportional constant of the PID controller.
  @computed
  double? get proportional => _pidConstants?.proportional;

  /// The integral constant of the PID controller.
  @computed
  double? get integral => _pidConstants?.integral;

  /// The derivative constant of the PID controller.
  @computed
  double? get derivative => _pidConstants?.derivative;

  @observable
  bool _isConstantsChanging = false;

  /// True if the store is in the process of fetching or changing constants.
  @computed
  bool get isConstantsChanging => _isConstantsChanging;

  /// True if the store is empty, meaning that no constants have been fetched yet.
  @computed
  bool get isEmpty => _pidConstants == null;

  // -----------------------
  // ACTIONS
  // -----------------------
  @action
  Future getConstants() async {
    _isConstantsChanging = true;
    try {
      _pidConstants = await _repository.pid.getConstants();
    } on Exception catch (exception) {
      _exceptionStore.push(exception);
      log('Exception occured on requesting PID constants: $exception');
    } catch (err) {
      log('Error occured on requesting PID constants: $err');
      rethrow;
    } finally {
      _isConstantsChanging = false;
    }
  }

  @action
  Future changeConstants({
    required double proportional,
    required double integral,
    required double derivative,
  }) async {
    _isConstantsChanging = true;
    try {
      _pidConstants = await _repository.pid.changeConstants(
        proportional: proportional,
        integral: integral,
        derivative: derivative,
      );
    } on Exception catch (exception) {
      _exceptionStore.push(exception);
      log('Exception occured when patching PID constants: $exception');
    } catch (err) {
      log('Error occured when patching PID constants: $err');
      rethrow;
    } finally {
      _isConstantsChanging = false;
    }
  }

  @action
  void _onData(WsInboundMessage message) {
    // if (message.payload is PidConstants && message.type == InboundMessageType.pidConstants) {
    //   var pidConstants = (message.payload as PidConstants);
    //   _isConstantsChanging = false;
    //   _pidConstants = pidConstants;
    // }
  }
}
