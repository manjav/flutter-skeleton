import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:get/get.dart';

import '../../app_export.dart';

class LoadingController extends GetxController {
  @override
  Future<void> onReady() async {
    super.onReady();
    var services = serviceLocator<ServicesProvider>();
    var accountProvider = serviceLocator<AccountProvider>();

    var context = Get.context!;

    Overlays.insert(
      Get.overlayContext!,
      const LoadingOverlay(),
    );

    serviceLocator<DeviceInfo>().initialize();

    await serviceLocator<Localization>().initialize(args: [Get.context!]);

    var trackers = serviceLocator<Trackers>();
    await trackers.initialize();

    var sounds = serviceLocator<Sounds>();
    sounds.initialize();
    sounds.playMusic();

    var ads = serviceLocator<Ads>();
    ads.initialize();
    ads.onUpdate = _onAdsServicesUpdate;

    serviceLocator<EventNotification>().initialize();

    try {
      var httpConnection = serviceLocator<HttpConnection>();
      var data = await httpConnection.initialize() as LoadingData;

      trackers.sendUserData("${data.account.id}", data.account.name);

      if (context.mounted) {
        accountProvider.initialize(data.account);

        var noobSocket = serviceLocator<NoobSocket>();
        noobSocket.initialize(
            args: [accountProvider, serviceLocator<OpponentsProvider>()]);

        serviceLocator<Payment>().init(
          storePackageName: FlavorConfig.instance.variables["storePackageName"],
          bindUrl: FlavorConfig.instance.variables["bindUrl"],
          enableDebugLogging: true,
        );

        services.changeState(ServiceStatus.initialize);

        serviceLocator<Inbox>().initialize(args: [context, data.account]);

        serviceLocator<Notifications>().initialize(
            args: ["${data.account.id}", data.account.getSchedules()]);
      }

      serviceLocator<Games>().initialize();

      services.changeState(ServiceStatus.complete);
    } on SkeletonException catch (e) {
      if (context.mounted) {
        services.changeState(ServiceStatus.error, exception: e);
      }
    }
  }

  _onAdsServicesUpdate(Placement? placement) {
    var sounds = serviceLocator<Sounds>();
    if (Pref.music.getBool()) {
      if (placement!.state == AdState.show) {
        sounds.pauseAll();
      } else if (placement.state == AdState.closed ||
          placement.state == AdState.failedShow) {
        sounds.resumeMusic();
      }
    }
  }
}
