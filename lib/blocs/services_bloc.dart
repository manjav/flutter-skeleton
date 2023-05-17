/// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/network_service.dart';
import '../services/ads_service.dart';
import '../services/analytics_service.dart';
import '../services/game_apis_service.dart';

class ServicesEvent {
  // final ServicesType type;
  // final int value;
  // ServicesEvent({required this.type, required this.value});
}

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
  // Map<dynamic, dynamic> data;
  // Services servicesData;

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

  servicesInit() {
    adsService.printTest();
    analyticsData.printTest();
    netConnectionData.printTest();
    gameApiData.printTest();
  }
}

enum ServicesType { data, wifi, offline }
