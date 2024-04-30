import 'package:get_it/get_it.dart';

import 'app_export.dart';

final serviceLocator = GetIt.instance;

void initServices() {
  serviceLocator.registerSingleton<ServicesProvider>(ServicesProvider());
  serviceLocator.registerSingleton<AccountProvider>(AccountProvider());
  serviceLocator.registerSingleton<OpponentsProvider>(OpponentsProvider());

  serviceLocator.registerLazySingleton<RouteService>(() => RouteService());
  serviceLocator.registerLazySingleton<DeviceInfo>(() => DeviceInfo());
  serviceLocator.registerLazySingleton<Localization>(() => Localization());
  serviceLocator.registerLazySingleton<Sounds>(() => Sounds());
  serviceLocator.registerLazySingleton<Trackers>(() => Trackers());
  serviceLocator
      .registerLazySingleton<EventNotification>(() => EventNotification());
  serviceLocator.registerLazySingleton<HttpConnection>(() => HttpConnection());
  serviceLocator.registerLazySingleton<NoobSocket>(() => NoobSocket());
  serviceLocator.registerLazySingleton<Notifications>(() => Notifications());
  serviceLocator.registerLazySingleton<Inbox>(() => Inbox());
  serviceLocator.registerLazySingleton<Games>(() => Games());
  serviceLocator.registerLazySingleton<Ads>(() => Ads());
  serviceLocator.registerLazySingleton<Payment>(() => Payment());
  serviceLocator.registerLazySingleton<TutorialManager>(() => TutorialManager());
  serviceLocator.registerLazySingleton<MissionManager>(() => MissionManager());
}
