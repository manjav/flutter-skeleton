import 'package:get/get.dart';
import 'package:lingai/views/screens/screen_speak.dart';
import 'package:lingai/views/screens/screen_stt.dart';

import '../../app_export.dart';

class LoadingController extends GetxController {
  @override
  Future<void> onReady() async {
    super.onReady();
    var services = serviceLocator<ServicesProvider>();
    Overlays.insert(
      Get.overlayContext!,
      const LoadingOverlay(),
    );

    var route = serviceLocator<RouteService>();
    route.pages = [
      SkeletonPageModel(page: HomeScreen(), route: Routes.home, isOpaque: true),
      SkeletonPageModel(
          page: SpeakScreen(), route: Routes.speak, isOpaque: true),
      SkeletonPageModel(page: ChatScreen(), route: Routes.chat, isOpaque: true),
      SkeletonPageModel(
          page: const STTScreen(), route: Routes.stt, isOpaque: true),
      SkeletonPageModel(
          page: const MessagePopup(),
          route: Routes.popupMessage,
          isOpaque: false),
      SkeletonPageModel(
          page: const MentorPopup(),
          route: Routes.popupMentor,
          isOpaque: false),
    ];

    serviceLocator<DeviceInfo>().initialize();

    await serviceLocator<Localization>().initialize(args: [Get.context!]);

    // var trackers = Trackers();
    // await trackers.initialize();
    // services.addService(trackers);

    var sounds = serviceLocator<Sounds>();
    sounds.initialize();

    serviceLocator<Speaker>().initialize();
    serviceLocator<STT>().initialize();

    try {
      await await serviceLocator<HttpConnection>().initialize();

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
