import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // await Firebase.initializeApp();
  await Prefs().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // static final firebaseAnalytics = FirebaseAnalytics.instance;
  // static final _observer =
  //     FirebaseAnalyticsObserver(analytics: firebaseAnalytics);

  @override
  createState() => _MyAppState();

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.restartApp();
  }
}

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver, ServiceFinderWidgetMixin {
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
      getService<Sounds>().playMusic();
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
          ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ],
        child: GetMaterialApp(
          // navigatorObservers: [MyApp._observer],
          localizationsDelegates: const [
            // AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
          ],
          supportedLocales: Localization.locales,
          theme: Themes.darkData,
          locale: Localization.locales.firstWhere((l) =>
              l.languageCode == Pref.language.getString(defaultValue: 'en')),
          // darkTheme: Themes.darkData,
          // themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          // onGenerateRoute: (RouteSettings routeSettings) {
          //   return MaterialTransparentRoute(
          //       isOpaque: RoutesExtension.getOpaque(routeSettings.name!),
          //       settings: routeSettings,
          //       builder: (BuildContext context) => RoutesExtension.getWidget(
          //           routeSettings.name!,
          //           args: routeSettings.arguments as Map<String, dynamic>?));
          // },
          home: LoadingScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
