import 'package:firebase_analytics/firebase_analytics.dart';

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
    network = Network();
    sound = Sound();
    trackers = TrackersService(firebaseAnalytics);
    gameApi = GamesService();
    adsService = AdsService();
    localization = Localization();
    prefs = Prefs();
    theme = MyTheme();
  }

  init() {
    network.initialize();
    sound.initialize();
    trackers.initialize();
    gameApi.initialize();
    adsService.initialize();
    localization.initialize();
    localization.initialize();
    prefs.initialize();
    theme.initialize();
  }
}
