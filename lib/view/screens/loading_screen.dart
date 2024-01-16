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
  void onRender(Duration timeStamp) {
    Overlays.insert(context, OverlayType.loading);
    var serviceProvider = context.read<ServicesProvider>();

    var firebaseAnalytics = FirebaseAnalytics.instance;

    var ads = Ads();
    ads.initialize();
    serviceProvider.addService(ads);

    serviceProvider.addService(Games());
    serviceProvider.addService(HttpConnection());
    serviceProvider.addService(DeviceInfo());
    serviceProvider.addService(Inbox());
    serviceProvider.addService(Localization());
    serviceProvider.addService(Notifications());
    serviceProvider.addService(NoobSocket());
    serviceProvider.addService(Sounds());
    serviceProvider.addService(Themes());
    serviceProvider.addService(Trackers(firebaseAnalytics));

    initialize();
  }

  initialize() async {
    var serviceProvider = context.read<ServicesProvider>();

    try {
      serviceProvider.get<DeviceInfo>().initialize();
      serviceProvider.get<Themes>().initialize();
      await serviceProvider.get<Localization>().initialize(args: [context]);
      await serviceProvider.get<Trackers>().initialize();

      // Load server data
      var data = await serviceProvider.get<HttpConnection>().initialize()
          as LoadingData;

      serviceProvider.get<Trackers>().sendUserData(data.account);
      if (context.mounted) {
        context.read<AccountProvider>().initialize(data.account);
        context.read<ServicesProvider>().changeState(ServiceStatus.initialize);

        // Initialize notifications ...
        serviceProvider.get<Notifications>().initialize(args: [data.account]);
      }

      // Initialize socket
      if (context.mounted) {
        serviceProvider.get<NoobSocket>().initialize(
            args: [data.account, context.read<OpponentsProvider>()]);
      }
    } on SkeletonException catch (e) {
      if (context.mounted) {
        serviceProvider.changeState(ServiceStatus.error, exception: e);
      }
    }

    serviceProvider.get<Games>().initialize();

    var ads = serviceProvider.get<Ads>();
    ads.initialize();
    ads.onUpdate = _onAdsServicesUpdate;

    serviceProvider.get<Sounds>().initialize();
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
