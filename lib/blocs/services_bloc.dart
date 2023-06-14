import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/ads/ads.dart';
import '../services/ads/ads_abstract.dart';
import '../services/connection/fake_connector.dart';
import '../services/connection/http_connection.dart';
import '../services/games.dart';
import '../services/localization.dart';
import '../services/prefs.dart';
import '../services/sounds.dart';
import '../services/theme.dart';
import '../services/trackers/trackers.dart';

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
  late IConnection connection;
  late ISounds sound;
  late Trackers trackers;
  late IGames games;
  late Ads adsService;
  late Localization localization;
  late Prefs prefs;
  late MyTheme theme;

  Services({required this.firebaseAnalytics}) : super(ServicesInit()) {
    prefs = Prefs();
    localization = Localization();
    connection = FakeConnector();
    sound = Sounds();
    trackers = Trackers(firebaseAnalytics);
    games = Games();
    adsService = Ads();
    theme = MyTheme();
  }

  Future<Response> initialize() async {
    theme.initialize();
    sound.initialize();
    await prefs.initialize();
    await localization.initialize();
    await trackers.initialize();
    await connection.initialize();
    games.initialize();
    adsService.initialize();
    adsService.onUpdate = _onAdsServicesUpdate;

//TODO added by hamiid
    return network.loadData();
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
