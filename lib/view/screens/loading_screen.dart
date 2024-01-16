import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_skeleton/app_export.dart';
import 'package:provider/provider.dart';

class LoadingScreen extends AbstractScreen {
  LoadingScreen({super.key}) : super(Routes.home, args: {});

  @override
  createState() => _LoadingScreenState();
}

class _LoadingScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  void onRender(Duration timeStamp) async {
    Overlays.insert(context, OverlayType.loading);
    var serviceProvider = context.read<ServicesProvider>();
    var accountProvider = context.read<AccountProvider>();

    var firebaseAnalytics = FirebaseAnalytics.instance;

    try {
      var deviceInfo = DeviceInfo();
      deviceInfo.initialize();
      serviceProvider.addService(deviceInfo);

      var themes = Themes();
      themes.initialize();
      serviceProvider.addService(themes);

      var inbox = Inbox();
      // await inbox.initialize(args: [context]);
      serviceProvider.addService(inbox);

      var localization = Localization();
      await localization.initialize(args: [context]);
      serviceProvider.addService(localization);

      var trackers = Trackers(firebaseAnalytics);
      await trackers.initialize();
      serviceProvider.addService(trackers);

      var httpConnection = HttpConnection();
      var data = await httpConnection.initialize() as LoadingData;
      serviceProvider.addService(httpConnection);

      trackers.sendUserData(data.account);

      if (context.mounted) {
        accountProvider.initialize(data.account);

        serviceProvider.changeState(ServiceStatus.initialize);

        var notifications = Notifications();
        notifications.initialize(args: [data.account]);
        serviceProvider.addService(notifications);

        var noobSocket = NoobSocket();
        noobSocket.initialize(
            args: [data.account, context.read<OpponentsProvider>()]);

        serviceProvider.addService(noobSocket);
      }
    } on SkeletonException catch (e) {
      if (context.mounted) {
        serviceProvider.changeState(ServiceStatus.error, exception: e);
      }
    }

    var games = Games();
    games.initialize();
    serviceProvider.addService(games);

    var ads = Ads();
    ads.initialize();
    ads.onUpdate = _onAdsServicesUpdate;
    serviceProvider.addService(ads);

    var sounds = Sounds();
    sounds.initialize();
    serviceProvider.addService(sounds);
  }

  _onAdsServicesUpdate(Placement? placement) {
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
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
