/// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/services/localization_service.dart';
import 'package:flutter_skeleton/services/sounds_service.dart';

import '../../services/network_service.dart';
import '../services/ads_service.dart';
import '../services/analytics_service.dart';
import '../services/game_apis_service.dart';

class ServicesEvent {}

//--------------------------------------------------------

abstract class ServicesState {
  final IAdsService adsService;
  final GameApisService gameApiService;
  final AnalyticsService analyticsService;
  final NetworkService networkService;
  final LocalizationService localizationService;
  final SoundService soundService;

  ServicesState({
    required this.gameApiService,
    required this.analyticsService,
    required this.networkService,
    required this.localizationService,
    required this.soundService,
    required this.adsService,
  });
}

class ServicesInit extends ServicesState {
  ServicesInit(
      {required super.gameApiService,
      required super.analyticsService,
      required super.networkService,
      required super.localizationService,
      required super.soundService,
      required super.adsService});
}

class ServicesUpdate extends ServicesState {
  ServicesUpdate(
      {required super.gameApiService,
      required super.analyticsService,
      required super.networkService,
      required super.localizationService,
      required super.soundService,
      required super.adsService});
}

//--------------------------------------------------------

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  IAdsService adsService;
  GameApisService gameApiService;
  AnalyticsService analyticsService;
  NetworkService networkService;
  LocalizationService localizationService;
  SoundService soundService;

  ServicesBloc(
      {required this.adsService,
      required this.gameApiService,
      required this.analyticsService,
      required this.networkService,
      required this.localizationService,
      required this.soundService})
      : super(ServicesInit(
            adsService: adsService,
            analyticsService: analyticsService,
            gameApiService: gameApiService,
            localizationService: localizationService,
            networkService: networkService,
            soundService: soundService)) {
    // on<ServicesEvent>(update);
  }

  initialize() async {
    await adsService.initialize();
    await analyticsService.initialize();
    await networkService.initialize();
    await gameApiService.initialize();
    await localizationService.initialize();
    await soundService.initialize();
  }
}

enum ServicesType { data, wifi, offline }
