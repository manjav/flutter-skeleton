import 'package:flutter/material.dart';

import '../../app_export.dart';

class LoadingScreen extends AbstractScreen {
  LoadingScreen({super.key}) : super(Routes.loading);

  @override
  createState() => _LoadingScreenState();
}

class _LoadingScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  void onRender(Duration timeStamp) async {
    Overlays.insert(
      context,
      const LoadingOverlay(),
    );

    var route = RouteService();
    route.pages = [
      SkeletonPageModel(
          page: LoadingScreen(), route: Routes.loading, isOpaque: true),
      SkeletonPageModel(page: HomeScreen(), route: Routes.home, isOpaque: true),
      SkeletonPageModel(
          page: const MessagePopup(), route: Routes.message, isOpaque: true),
    ];
    services.addService(route);

    var deviceInfo = DeviceInfo();
    deviceInfo.initialize();
    services.addService(deviceInfo);

    var themes = Themes();
    themes.initialize();
    services.addService(themes);

    var localization = Localization();
    await localization.initialize(args: [context]);
    services.addService(localization);

    // var trackers = Trackers();
    // await trackers.initialize();
    // services.addService(trackers);

    await Future.delayed(const Duration(milliseconds: 10));
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
    services.addService(sounds);
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

  @override
  Widget build(BuildContext context) => const SizedBox();
}
