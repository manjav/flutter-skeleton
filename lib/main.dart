import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/localization_service.dart';
import '../services/sounds_service.dart';
import '../services/theme.dart';
import 'blocs/services_bloc.dart';
import 'services/ads_service.dart';
import 'services/analytics_service.dart';
import 'services/game_apis_service.dart';
import 'services/network_service.dart';
import 'view/pages/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
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
    ThemeService theme = MyTheme();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServicesBloc(
              adsService: adsData,
              gameApiService: gameApi,
              analyticsService: analytics,
              networkService: netConnection,
              localizationService: localization,
              soundService: sounds,
              themeSevice: theme),
        ),
      ],
      child: const MaterialApp(home: LoadingScreen()),
    );
  }
}
