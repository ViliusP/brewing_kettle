import 'package:flutter/foundation.dart';

class RouteInfo {
  final String? name;
  final String? path;
  final Map<String, String> parameters;

  const RouteInfo({required this.name, required this.path, required this.parameters});

  const RouteInfo.empty() : name = null, path = null, parameters = const {};

  @override
  String toString() {
    return 'RouteInfo{name: $name, path: $path, parameters: $parameters}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RouteInfo &&
        other.name == name &&
        other.path == path &&
        mapEquals(other.parameters, parameters);
  }

  @override
  int get hashCode {
    return name.hashCode ^ path.hashCode ^ parameters.hashCode;
  }
}
