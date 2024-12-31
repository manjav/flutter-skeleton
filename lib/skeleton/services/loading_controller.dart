import 'package:get/get.dart';

import '../../app_export.dart';

class LoadingController extends GetxController {
  @override
  Future<void> onReady() async {
    super.onReady();
    var services = serviceLocator<ServicesProvider>();
    Overlays.insert(Get.overlayContext!, const LoadingOverlay());

    serviceLocator<DeviceInfo>().initialize();
    await serviceLocator<Trackers>().initialize();

    serviceLocator<ListenerQuiz>().initialize();
    serviceLocator<Trackers>().design("ls|listener");

    try {
      var data = await serviceLocator<NetConnector>().initialize();

      var account = serviceLocator<AccountProvider>();
      account.initialize(data);
      serviceLocator<Trackers>().design("ls|account_init");

      await serviceLocator<Localization>().initialize(args: [
        account.account.user.langTag ?? "mx",
        account.metadata["targetLanguage"] ?? "en",
      ]);

      services.changeState(ServiceStatus.initialize);

      serviceLocator<Trackers>().sendUserData(
        userId: account.account.user.id,
        userName: account.account.user.username!,
        createTime: account.account.user.createTime,
        updateTime: account.account.user.updateTime,
        nativeLanguage: account.account.user.langTag,
      );

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
