import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'app_export.dart';

void main() async {
  MyApp.startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // await Firebase.initializeApp();
  await Prefs().initialize();

  initServices();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static late final DateTime startTime;
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
      serviceLocator<Sounds>().playMusic();
    }
  }

  void restartApp() async {
    Overlays.clear();
    LoaderWidget.cachedLoaders.clear();

    Get.reset(clearRouteBindings: true);

    await serviceLocator.reset();
    initServices();

    if (mounted) if (Navigator.canPop(context)) Navigator.pop(context);

    _initialize(true);
  }

  _initialize([bool forced = false]) async {
    if (key == null || forced) {
      key = UniqueKey();
    }
    var result = await DeviceInfo.preInitialize(context, forced);
    if (result) {
      Themes.preInitialize();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialize();
    if (!DeviceInfo.isPreInitialized) {
      return const SizedBox();
    }
    return KeyedSubtree(
      key: key,
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
        getPages: [
          _getPage(Routes.home, () => HomeScreen()),
          _getPage(Routes.popupMessage, () => const MessagePopup(), false),
        ],
        initialRoute: Routes.home,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  GetPage<dynamic> _getPage(String routeName, page, [bool opaque = true]) =>
      GetPage(name: Routes.home, page: () => HomeScreen(), opaque: opaque);
}
