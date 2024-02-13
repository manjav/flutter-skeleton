import 'package:get_it/get_it.dart';

import 'app_export.dart';

final serviceLocator = GetIt.instance;

void initServices() {
  serviceLocator.registerSingleton<ServicesProvider>(ServicesProvider());

  serviceLocator.registerLazySingleton<RouteService>(() => RouteService());
  serviceLocator.registerLazySingleton<DeviceInfo>(() => DeviceInfo());
  serviceLocator.registerLazySingleton<Localization>(() => Localization());
  serviceLocator.registerLazySingleton<Sounds>(() => Sounds());
}
