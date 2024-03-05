import 'package:get/get.dart';

import '../../app_export.dart';

class LoadingController extends GetxController {
  @override
  Future<void> onReady() async {
    super.onReady();
    var services = serviceLocator<ServicesProvider>();
    Overlays.insert(Get.overlayContext!, const LoadingOverlay());

    serviceLocator<DeviceInfo>().initialize();

    await serviceLocator<Localization>().initialize(args: [Get.context!]);

    // var trackers = Trackers();
    // await trackers.initialize();
    // services.addService(trackers);

    var sounds = serviceLocator<Sounds>();
    sounds.initialize();

    serviceLocator<Speaker>().initialize();

    try {
      var data = await serviceLocator<NetConnector>().initialize();
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

      services.changeState(ServiceStatus.complete);
    } on SkeletonException catch (e) {
      services.changeState(ServiceStatus.error, exception: e);
    }
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
