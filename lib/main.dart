import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/services/localization_service.dart';
import 'package:flutter_skeleton/services/sounds_service.dart';
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
  // NetworkService network = Network();
  // SoundService sound = Sounds();
  // GameApisService gameApi = MainGameApi();
  // AnalyticsService analytics = Analytics();
  // IAdsService ads = AdsService(analytics: analytics, sound: sound);

  runApp(MyApp(
      // netConnectionData: network,
      // gameApiData: gameApi,
      // adsData: ads,
      // analyticsData: analytics,
      ));
}

class MyApp extends StatelessWidget {
  // final IAdsService adsData;
  // final GameApisService gameApiData;
  // final NetworkService netConnectionData;
  // final AnalyticsService analyticsData;

  const MyApp({
    super.key,
    // required this.adsData,
    // required this.gameApiData,
    // required this.analyticsData,
    // required this.netConnectionData,
  });

  @override
  Widget build(BuildContext context) {
    NetworkService netConnection = Network();
    SoundService sound = Sounds();
    GameApisService gameApi = MainGameApi();
    AnalyticsService analytics = Analytics();
    IAdsService adsData = AdsService(analytics: analytics, sound: sound);
    LocalizationService localization = ILocalization();
    SoundService sounds = Sounds();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServicesBloc(
              adsService: adsData,
              gameApiService: gameApi,
              analyticsService: analytics,
              networkService: netConnection,
              localizationService: localization,
              soundService: sounds),
        ),
      ],
      child: const MaterialApp(home: LoadingScreen()),
    );
  }
}
