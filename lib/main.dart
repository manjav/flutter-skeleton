import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'data/core/adam.dart';
import 'mixins/service_finder_mixin.dart';
import 'providers/account_provider.dart';
import 'providers/opponents_provider.dart';
import 'providers/services_provider.dart';
import 'services/device_info.dart';
import 'services/localization.dart';
import 'services/prefs.dart';
import 'services/sounds.dart';
import 'services/theme.dart';
import 'view/overlays/overlay.dart';
import 'view/route_provider.dart';
import 'view/widgets/loader_widget.dart';

void main() async {
  MyApp.startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
  UniqueKey? key;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
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
    Overlays.clear();
    LoaderWidget.cachedLoaders.clear();
    if (Navigator.canPop(context)) Navigator.pop(context);
    _initialize(true);
  }

  _initialize([bool forced = false]) async {
    if (key == null || forced) {
      key = UniqueKey();
    }
    var result = await DeviceInfo.preInitialize(context, forced);
    if (result) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialize();
    if (!DeviceInfo.isPreInitialized) return const SizedBox();
    return KeyedSubtree(
        key: key,
        child: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                  create: (_) => ServicesProvider(MyApp._firebaseAnalytics)),
              ChangeNotifierProvider(create: (_) => AccountProvider()),
              ChangeNotifierProvider(create: (_) => OpponentsProvider())
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
