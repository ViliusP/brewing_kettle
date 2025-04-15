import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/ui/brew_kettle_dashboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:async';

import 'package:flutter/widgets.dart';

Future<void> main() async {
  LicenseRegistry.addLicense(() async* {
    final nunitoSansLicence = await rootBundle.loadString('assets/fonts/NunitoSans/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], nunitoSansLicence);
  });

  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.configure();
  runApp(BrewKettleDashboard());
}
