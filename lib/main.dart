import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fc_project/viewModel/bloc/services_bloc.dart';

import 'blocs/services_bloc.dart';
import 'services/ads_service.dart';
import 'services/analytics_service.dart';
import 'services/game_apis_service.dart';
import 'services/network_service.dart';
import 'view/pages/loading_screen.dart';

// import 'viewModel/bloc/currency_bloc.dart';
// import 'viewModel/bloc/missions_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NetworkService network = Network();
  GameApisService gameApi = MainAPI();
  IAdsService ads = AdsService();
  AnalyticsService analytics = Analytics();

  // ByteHTTP local = ByteHTTP();
  // local.getByteData();
//
  // NetConnection connectionRes = await connection.connect();
  // GameApi gameApiRes = await gameApi.connect();
  // Ads adsRes = await ads.initialize();
  // Analytics analyticsRes = await analytics.initialize();

  runApp(MyApp(
    netConnectionData: network,
    gameApiData: gameApi,
    adsData: ads,
    analyticsData: analytics,
  ));
}

class MyApp extends StatelessWidget {
  final IAdsService adsData;
  final GameApisService gameApiData;
  final NetworkService netConnectionData;
  final AnalyticsService analyticsData;

  const MyApp({
    super.key,
    required this.adsData,
    required this.gameApiData,
    required this.analyticsData,
    required this.netConnectionData,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServicesBloc(
              adsService: adsData,
              gameApiData: gameApiData,
              analyticsData: analyticsData,
              netConnectionData: netConnectionData),
        ),
        // BlocProvider(
        //   create: (context) => ConnectioBloc(connectionData: netConnectionData),
        // ),
        // BlocProvider(
        //   create: (context) => GameApiBloc(gameApiData: gameApiData),
        // ),
        // BlocProvider(
        //   create: (context) => AnalyticsBloc(analyticsData: analyticsData),
        // ),
      ],
      child: const MaterialApp(home: LoadingScreen()),
    );
  }
}
