import 'package:get/get.dart';

import '../../app_export.dart';

class LoadingController extends GetxController with ServiceFinderMixin {
  @override
  Future<void> onReady() async {
    super.onReady();
    var services = getServices(Get.context!);
    Overlays.insert(
      Get.overlayContext!,
      const LoadingOverlay(),
    );

    var route = RouteService();
    route.pages = [
      SkeletonPageModel(page: HomeScreen(), route: Routes.home, isOpaque: true),
      SkeletonPageModel(
          page: const MessagePopup(),
          route: Routes.popupMessage,
          isOpaque: false),
    ];
    services.addService(route);

    var deviceInfo = DeviceInfo();
    deviceInfo.initialize();
    services.addService(deviceInfo);

    var themes = Themes();
    themes.initialize();
    services.addService(themes);

    var localization = Localization();
    await localization.initialize(args: [Get.context!]);
    services.addService(localization);

    // var trackers = Trackers();
    // await trackers.initialize();
    // services.addService(trackers);

    await Future.delayed(const Duration(milliseconds: 500));
    services.changeState(ServiceStatus.initialize);

    // var notifications = Notifications();
    // notifications.initialize(args: ["", <String, int>{}]);
    // serviceProvider.addService(notifications);

    // var games = Games();
    // games.initialize();
    // services.addService(games);

    // var ads = Ads();
    // ads.initialize();
    // ads.onUpdate = _onAdsServicesUpdate;
    // services.addService(ads);

    var sounds = Sounds();
    sounds.initialize();
    sounds.playMusic();
    services.addService(sounds);
    services.changeState(ServiceStatus.complete);
  }

  /* _onAdsServicesUpdate(Placement? placement) {
    var sounds = services.get<Sounds>();
    if (Pref.music.getBool()) {
      if (placement!.state == AdState.show) {
        sounds.stopAll();
      } else if (placement.state == AdState.closed ||
          placement.state == AdState.failedShow) {
        sounds.playMusic();
      }
    }
  } */
}
