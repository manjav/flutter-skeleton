import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/ads/ads_abstract.dart';
import '../services/ads/ads_service.dart';
import '../services/game_service.dart';
import '../services/localization.dart';
import '../services/network.dart';
import '../services/prefs.dart';
import '../services/sounds.dart';
import '../services/theme.dart';
import '../services/trackers/trackers_service.dart';

class ServicesEvent {}

//--------------------------------------------------------

abstract class ServicesState {
  ServicesState();
}

class ServicesInit extends ServicesState {
  ServicesInit();
}

class ServicesUpdate extends ServicesState {
  ServicesUpdate();
}

//--------------------------------------------------------

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  FirebaseAnalytics firebaseAnalytics;
  late INetwork network;
  late ISound sound;
  late TrackersService trackers;
  late IGameService gameApi;
  late AdsService adsService;
  late Localization localization;
  late Prefs prefs;
  late MyTheme theme;

  ServicesBloc({required this.firebaseAnalytics}) : super(ServicesInit()) {
    prefs = Prefs();
    localization = Localization();
    network = Network();
    sound = Sound();
    trackers = TrackersService(firebaseAnalytics);
    gameApi = GamesService();
    adsService = AdsService();
    theme = MyTheme();
  }

  initialize() async {
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
