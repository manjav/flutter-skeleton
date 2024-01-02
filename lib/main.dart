import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'blocs/account_bloc.dart';
import 'blocs/opponents_bloc.dart';
import 'blocs/services_bloc.dart';
import 'data/core/adam.dart';
import 'mixins/service_provider.dart';
import 'services/device_info.dart';
import 'services/localization.dart';
import 'services/prefs.dart';
import 'services/sounds.dart';
import 'services/theme.dart';
import 'view/route_provider.dart';
import 'view/widgets/loader_widget.dart';

void main() async {
  MyApp.startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Firebase.initializeApp();
  await Prefs().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static late final DateTime startTime;
  const MyApp({super.key});

  static final _firebaseAnalytics = FirebaseAnalytics.instance;
  static final _observer =
      FirebaseAnalyticsObserver(analytics: _firebaseAnalytics);

  @override
  createState() => _MyAppState();

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.restartApp();
  }
}

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver, ServiceProvider {
  late UniqueKey key;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // getService<Sounds>(context).stopAll();
    } else if (state == AppLifecycleState.resumed) {
      getService<Sounds>(context).playMusic();
    }
  }

  void restartApp() {
    Ranks.lists.clear();
    LoaderWidget.cachedLoaders.clear();
    setState(() => _initialize());
  }

  void _initialize() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    key = UniqueKey();
    DeviceInfo.size = Size.zero;
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
        key: key,
        child: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => ServicesBloc(
                      firebaseAnalytics: MyApp._firebaseAnalytics)),
              BlocProvider(create: (context) => AccountBloc()),
              BlocProvider(create: (context) => OpponentsBloc())
            ],
            child: MaterialApp(
                navigatorObservers: [
                  MyApp._observer
                ],
                localizationsDelegates: const [
                  // AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                ],
                supportedLocales: Localization.locales,
                theme: Themes.darkData,
                locale: Localization.locales.firstWhere((l) =>
                    l.languageCode ==
                    Pref.language.getString(defaultValue: 'en')),
                // darkTheme: Themes.darkData,
                // themeMode: settingsController.themeMode,

                // Define a function to handle named routes in order to support
                // Flutter web url navigation and deep linking.
                onGenerateRoute: (RouteSettings routeSettings) {
                  return MaterialTransparentRoute(
                      isOpaque: RouteProvider.getOpaque(routeSettings.name!),
                      settings: routeSettings,
                      builder: (BuildContext context) =>
                          RouteProvider.getWidget(routeSettings.name!,
                              args: routeSettings.arguments
                                  as Map<String, dynamic>?));
                })));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
