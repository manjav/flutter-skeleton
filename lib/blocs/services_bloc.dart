import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/localization_service.dart';
import '../services/prefs_service.dart';
import '../services/sounds_service.dart';
import '../services/theme.dart';
import '../services/network_service.dart';
import '../services/ads_service.dart';
import '../services/trackers/trackers_service.dart';
import '../services/game_apis_service.dart';

class ServicesEvent {}

//--------------------------------------------------------

abstract class ServicesState {
  final IAdsService adsService;
  final GameApisService gameApiService;
  final TrackersService analyticsService;
  final LocalizationService localizationService;
  final NetworkService networkService;
  final PrefsService prefsService;
  final SoundService soundService;
  final ThemeService themeService;

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
  IAdsService adsService;
  GameApisService gameApiService;
  TrackersService trackers;
  LocalizationService localizationService;
  NetworkService networkService;
  SoundService soundService;
  ThemeService themeSevice;
  PrefsService prefsService;

  ServicesBloc({
    required this.adsService,
    required this.gameApiService,
    required this.trackers,
    required this.localizationService,
    required this.networkService,
    required this.prefsService,
    required this.soundService,
    required this.themeSevice,
  }) : super(ServicesInit(
          adsService: adsService,
          analyticsService: trackers,
          gameApiService: gameApiService,
          localizationService: localizationService,
          networkService: networkService,
          prefsService: prefsService,
          soundService: soundService,
          themeService: themeSevice,
        )) {
    // on<ServicesEvent>(update);
  }

  initialize() async {
    await prefsService.initialize();
    await localizationService.initialize();
    await themeSevice.initialize();
    await soundService.initialize();
    await gameApiService.initialize();
    await networkService.initialize();
    await trackers.initialize();
    await adsService.initialize();
  }
}
