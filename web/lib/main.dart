import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/screens/brew_kettle_dashboard.dart';

import 'dart:async';

import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.configure();
  runApp(BrewKettleDashboard());
}
