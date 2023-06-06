import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/core/ads/ads_service.dart';
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
  final AdsService adsService;
  final IGameService gameApiService;
  final TrackersService analyticsService;
  final Localization localizationService;
  final INetwork networkService;
  final Prefs prefsService;
  final ISound soundService;
  final ITheme themeService;

  ServicesState({
    required this.prefsService,
    required this.gameApiService,
    required this.adsService,
    required this.analyticsService,
    required this.networkService,
    required this.localizationService,
    required this.soundService,
    required this.themeService,
  });
}

class ServicesInit extends ServicesState {
  ServicesInit({
    required super.prefsService,
    required super.gameApiService,
    required super.analyticsService,
    required super.networkService,
    required super.localizationService,
    required super.soundService,
    required super.adsService,
    required super.themeService,
  });
}

class ServicesUpdate extends ServicesState {
  ServicesUpdate({
    required super.prefsService,
    required super.gameApiService,
    required super.analyticsService,
    required super.networkService,
    required super.localizationService,
    required super.soundService,
    required super.adsService,
    required super.themeService,
  });
}

//--------------------------------------------------------

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  AdsService adsService;
  IGameService gameApiService;
  TrackersService trackers;
  Localization localization;
  INetwork network;
  ISound sound;
  ITheme theme;
  Prefs prefs;

  ServicesBloc({
    required this.adsService,
    required this.gameApiService,
    required this.trackers,
    required this.localization,
    required this.network,
    required this.prefs,
    required this.sound,
    required this.theme,
  }) : super(ServicesInit(
          adsService: adsService,
          analyticsService: trackers,
          gameApiService: gameApiService,
          localizationService: localization,
          networkService: network,
          prefsService: prefs,
          soundService: sound,
          themeService: theme,
        )) {
    // on<ServicesEvent>(update);
  }

  initialize() async {
    await prefs.initialize();
    await localization.initialize();
    await theme.initialize();
    await sound.initialize();
    await gameApiService.initialize();
    await network.initialize();
    await trackers.initialize();
    await adsService.initialize();
  }
}
