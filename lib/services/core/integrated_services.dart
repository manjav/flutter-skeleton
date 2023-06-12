import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_skeleton/services/core/ads/ads_abstract.dart';

import '../game_service.dart';
import '../localization.dart';
import '../network.dart';
import '../prefs.dart';
import '../sounds.dart';
import '../theme.dart';
import '../trackers/trackers_service.dart';
import 'ads/ads_service.dart';

class IntegratedServices {
  late INetwork network;
  late ISound sound;
  late TrackersService trackers;
  late IGameService gameApi;
  late AdsService adsService;
  late Localization localization;
  late Prefs prefs;
  late ITheme theme;

  IntegratedServices({required FirebaseAnalytics firebaseAnalytics}) {
    prefs = Prefs();
    localization = Localization();
    network = Network();
    sound = Sound();
    trackers = TrackersService(firebaseAnalytics);
    gameApi = GamesService();
    adsService = AdsService();
    theme = MyTheme();
  }

  init() async {
    theme.initialize();
    sound.initialize();
    await prefs.initialize();
    await localization.initialize();
    await trackers.initialize();
    network.initialize();
    gameApi.initialize();
    adsService.initialize();
    adsService.onUpdate = _onAdsServicesUpdate;
  }

  _onAdsServicesUpdate(Placement? placement) {
    if (Prefs.getBool("settings_music")) {
      if (placement!.state == AdState.show) {
        // sound.stop("music");
      } else if (placement.state == AdState.closed ||
          placement.state == AdState.failedShow) {
        // sound.play("african-fun", channel: "music");
      }
    }
  }
}
