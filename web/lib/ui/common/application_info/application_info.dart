import 'package:flutter/widgets.dart';

class ApplicationInfo extends InheritedWidget {
  const ApplicationInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.packageName,
    required this.installTime,
    required this.updateTime,
    super.key,
    required super.child,
  });

  /// The name of the application.
  final String appName;

  /// The package name (for example `com.example.app`).
  final String packageName;

  final String version;
  final String buildNumber;

  final DateTime? installTime;
  final DateTime? updateTime;

  static ApplicationInfo? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ApplicationInfo>();
  }

  static ApplicationInfo of(BuildContext context) {
    final ApplicationInfo? result = maybeOf(context);
    assert(result != null, 'No ApplicationInfo found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ApplicationInfo oldWidget) =>
      appName != oldWidget.appName ||
      version != oldWidget.version ||
      buildNumber != oldWidget.buildNumber ||
      packageName != oldWidget.packageName ||
      installTime != oldWidget.installTime ||
      updateTime != oldWidget.updateTime;
}
