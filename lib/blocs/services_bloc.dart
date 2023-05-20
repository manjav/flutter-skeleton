/// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/network_service.dart';
import '../services/ads_service.dart';
import '../services/analytics_service.dart';
import '../services/game_apis_service.dart';

class ServicesEvent {}

//--------------------------------------------------------

abstract class ServicesState {
  final IAdsService adsService;
  final GameApisService gameApiData;
  final AnalyticsService analyticsData;
  final NetworkService netConnectionData;

  ServicesState(
      {required this.adsService,
      required this.gameApiData,
      required this.analyticsData,
      required this.netConnectionData});
}

class ServicesInit extends ServicesState {
  ServicesInit({
    required super.adsService,
    required super.gameApiData,
    required super.analyticsData,
    required super.netConnectionData,
  });
}

class ServicesUpdate extends ServicesState {
  ServicesUpdate(
      {required super.adsService,
      required super.gameApiData,
      required super.analyticsData,
      required super.netConnectionData});
}

//--------------------------------------------------------

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  IAdsService adsService;
  GameApisService gameApiData;
  AnalyticsService analyticsData;
  NetworkService netConnectionData;

  ServicesBloc(
      {required this.adsService,
      required this.gameApiData,
      required this.analyticsData,
      required this.netConnectionData})
      : super(ServicesInit(
            adsService: adsService,
            gameApiData: gameApiData,
            analyticsData: analyticsData,
            netConnectionData: netConnectionData)) {
    // on<ServicesEvent>(update);
  }

  initialize() {
    adsService.log("adsService");
    analyticsData.log("analyticsService");
    netConnectionData.log("netConnectionService");
    gameApiData.log("gameApiService");
  }
}

enum ServicesType { data, wifi, offline }
