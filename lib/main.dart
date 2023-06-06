import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/services_bloc.dart';
import 'services/core/ads/ads_service.dart';
import 'services/game_apis_service.dart';
import 'services/localization_service.dart';
import 'services/network_service.dart';
import 'services/prefs_service.dart';
import 'services/sounds_service.dart';
import 'services/theme.dart';
import 'services/trackers/trackers_service.dart';
import 'view/pages/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  //NOTE: would be included later
  static final _firebaseAnalytics = FirebaseAnalytics.instance;
  static final _observer =
      FirebaseAnalyticsObserver(analytics: _firebaseAnalytics);

  @override
  Widget build(BuildContext context) {
    NetworkService netConnection = Network();
    SoundService sound = Sounds();
    TrackersService trackers = TrackersService(_firebaseAnalytics);
    GameApisService gameApi = Games();
    AdsService adsData = AdsService();
    LocalizationService localization = ILocalization();
    PrefsService prefsService = PrefsService();
    ThemeService theme = MyTheme();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServicesBloc(
              adsService: adsData,
              gameApiService: gameApi,
              trackers: trackers,
              localizationService: localization,
              networkService: netConnection,
              prefsService: prefsService,
              soundService: sound,
              themeSevice: theme),
        ),
      ],
      child: MaterialApp(
          home: const LoadingScreen(), navigatorObservers: [_observer]),
    );
  }
}
