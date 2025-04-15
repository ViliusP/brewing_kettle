import 'package:brew_kettle_dashboard/constants/app.dart';
import 'package:brew_kettle_dashboard/constants/theme.dart';
import 'package:brew_kettle_dashboard/core/service_locator.dart';
import 'package:brew_kettle_dashboard/localizations/localization.dart';
import 'package:brew_kettle_dashboard/stores/locale/locale_store.dart';
import 'package:brew_kettle_dashboard/stores/theme/theme_store.dart';
import 'package:brew_kettle_dashboard/ui/common/application_info/application_info.dart';
import 'package:brew_kettle_dashboard/ui/routing.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BrewKettleDashboard extends StatefulWidget {
  const BrewKettleDashboard({super.key});

  @override
  State<BrewKettleDashboard> createState() => _BrewKettleDashboardState();
}

class _BrewKettleDashboardState extends State<BrewKettleDashboard> {
  final LocaleStore _localeStore = getIt<LocaleStore>();
  final ThemeStore _themeStore = getIt<ThemeStore>();

  PackageInfo? packageInfo;

  @override
  void initState() {
    PackageInfo.fromPlatform().then((value) {
      packageInfo = value;
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = MaterialTheme.createTextTheme(context, AppDefaults.font);
    MaterialTheme materialTheme = MaterialTheme(textTheme);

    return Observer(
      builder: (context) {
        return MaterialApp.router(
          actions: WidgetsApp.defaultActions,
          scrollBehavior: AppScrollBehavior(),
          builder: (context, child) {
            if (packageInfo == null) {
              return child!;
            }

            return ApplicationInfo(
              appName: packageInfo!.appName,
              version: packageInfo!.version,
              buildNumber: packageInfo!.buildNumber,
              packageName: packageInfo!.packageName,
              installTime: packageInfo?.installTime,
              updateTime: packageInfo?.updateTime,
              child: child!,
            );
          },
          routerConfig: AppRouter.value,
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: materialTheme.theme(_themeStore.theme.colorScheme),
          locale: _localeStore.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        );
      },
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    // When modifying this function, consider modifying the implementation in
    // the base class ScrollBehavior as well.
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return child;
      case TargetPlatform.linux:
      case TargetPlatform.windows:
      case TargetPlatform.android:
        return StretchingOverscrollIndicator(
          axisDirection: details.direction,
          clipBehavior: details.clipBehavior ?? Clip.hardEdge,
          child: child,
        );

      case TargetPlatform.fuchsia:
        break;
    }
    return GlowingOverscrollIndicator(
      axisDirection: details.direction,
      color: Theme.of(context).colorScheme.secondary,
      child: child,
    );
  }
}
