import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';

class StoreWebSocketListener {
  final String name;

  /// Message type
  final InboundMessageType type;

  final void Function(WsInboundMessage) onData;

  final Function? onError;
  final void Function()? onDone;

  StoreWebSocketListener(this.onData, this.type, this.name, {this.onError, this.onDone});
}
