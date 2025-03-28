import 'package:brew_kettle_dashboard/stores/store_di.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> configure() async {
    await StoreModule.inject(getIt);
    // await DomainLayerInjection.configureDomainLayerInjection();
    // await PresentationLayerInjection.configurePresentationLayerInjection();
  }
}
