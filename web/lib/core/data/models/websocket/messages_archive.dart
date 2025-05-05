import 'dart:collection';
import 'dart:convert';

import 'package:brew_kettle_dashboard/core/data/models/websocket/inbound_message.dart';
import 'package:brew_kettle_dashboard/utils/list_extensions.dart';
import 'package:flutter/foundation.dart';

class MessagesArchive {
  UnmodifiableListView<WsInboundMessageSimple> get data => UnmodifiableListView(_data);

  final List<WsInboundMessageSimple> _data = [];

  MessagesArchive();

  void add(WsInboundMessageSimple value) {
    _data.add(value);
  }

  void clear() => _data.clear();

  void combine(MessagesArchive other) {
    _data.addAll(other._data);
    _data.sort((a, b) => a.time.compareTo(b.time));
  }

  String get jsonLog {
    if (_data.isEmpty) return "[]"; // Handle empty list case

    var jsonObjects = _data
        .takeLast(3)
        .map((e) {
          return jsonEncode(e.asJsonMap);
        })
        .join(",\n");
    return "[$jsonObjects]";
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessagesArchive && listEquals(_data, other._data);
  }

  @override
  int get hashCode => Object.hashAll(_data);
}
