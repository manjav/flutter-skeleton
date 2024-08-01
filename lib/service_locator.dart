import 'package:get_it/get_it.dart';

import 'app_export.dart';

final serviceLocator = GetIt.instance;

void initServices() {
  serviceLocator.registerSingleton<ServicesProvider>(ServicesProvider());

  serviceLocator.registerLazySingleton<DeviceInfo>(() => DeviceInfo());
  serviceLocator.registerLazySingleton<Localization>(() => Localization());
  serviceLocator.registerLazySingleton<DictatorQuiz>(() => DictatorQuiz());
  serviceLocator.registerLazySingleton<ListenerQuiz>(() => ListenerQuiz());
  serviceLocator.registerLazySingleton<Speaker>(() => Speaker());
  serviceLocator.registerLazySingleton<Sounds>(() => Sounds());
  serviceLocator.registerLazySingleton<NetConnector>(() => NetConnector());
  serviceLocator.registerLazySingleton<Trackers>(() => Trackers());
  serviceLocator
      .registerLazySingleton<AccountProvider>(() => AccountProvider());
}
