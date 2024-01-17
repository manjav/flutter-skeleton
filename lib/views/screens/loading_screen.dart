import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_export.dart';

class LoadingScreen extends AbstractScreen {
  LoadingScreen({super.key}) : super(Routes.LOADING_SCREEN, args: {});

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
    var serviceProvider = context.read<ServicesProvider>();

    var route = RouteService();
    route.pages = [
      SkeletonPageModel(
          page: LoadingScreen(), route: Routes.LOADING_SCREEN, isOpaque: true),
      SkeletonPageModel(
          page: HomeScreen(), route: Routes.HOME_SCREEN, isOpaque: true),
      SkeletonPageModel(
          page: const MessagePopup(args: {}),
          route: Routes.POPUP_MESSAGE,
          isOpaque: true),
    ];
    serviceProvider.addService(route);

    var deviceInfo = DeviceInfo();
    deviceInfo.initialize();
    serviceProvider.addService(deviceInfo);

    var themes = Themes();
    themes.initialize();
    serviceProvider.addService(themes);

    var localization = Localization();
    await localization.initialize(args: [context]);
    serviceProvider.addService(localization);

    // var trackers = Trackers(FirebaseAnalytics.instance);
    // await trackers.initialize();
    // serviceProvider.addService(trackers);

    serviceProvider.changeState(ServiceStatus.initialize);

    // var notifications = Notifications();
    // notifications.initialize(args: ["", <String, int>{}]);
    // serviceProvider.addService(notifications);

    var games = Games();
    games.initialize();
    serviceProvider.addService(games);

    // var ads = Ads();
    // ads.initialize();
    // ads.onUpdate = _onAdsServicesUpdate;
    // serviceProvider.addService(ads);

    var sounds = Sounds();
    sounds.initialize();
    serviceProvider.addService(sounds);
  }

  /* _onAdsServicesUpdate(Placement? placement) {
    var serviceProvider = context.read<ServicesProvider>();
    Sounds sounds = serviceProvider.get<Sounds>();

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
