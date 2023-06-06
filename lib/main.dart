import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/services_bloc.dart';
import 'services/core/ads/ads_service.dart';
import 'services/game_service.dart';
import 'services/localization.dart';
import 'services/network.dart';
import 'services/prefs.dart';
import 'services/sounds.dart';
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
    INetwork network = Network();
    ISound sound = Sound();
    TrackersService trackers = TrackersService(_firebaseAnalytics);
    IGameService gameApi = GamesService();
    AdsService adsService = AdsService();
    Localization localization = Localization();
    Prefs prefs = Prefs();
    ITheme theme = MyTheme();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ServicesBloc(
              adsService: adsService,
              gameApiService: gameApi,
              trackers: trackers,
              localization: localization,
              network: network,
              prefs: prefs,
              sound: sound,
              theme: theme),
        ),
      ],
      child: MaterialApp(
          home: const LoadingScreen(), navigatorObservers: [_observer]),
    );
  }
}
