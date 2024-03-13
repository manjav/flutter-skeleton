import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'app_export.dart';

void main() async {
  MyApp.startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
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
      // serviceLocator<Sounds>().stopAll();
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
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => serviceLocator<ServicesProvider>()),
          ChangeNotifierProvider(
              create: (_) => serviceLocator<AccountProvider>()),
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
          locale:
              Localization.locales.firstWhere((l) => l.languageCode == "en"),
          getPages: [
            _getPage(Routes.home, HomeScreen()),
            _getPage(Routes.word, LessonWordScreen()),
            _getPage(Routes.match, LessonMatchScreen()),
            _getPage(Routes.speak, LessonSpeakScreen()),
            _getPage(Routes.dictation, LessonDictationScreen()),
            _getPage(Routes.onboarding, OnboardingScreen()),
            _getPage(Routes.popupMentor, const MentorPopup(), false),
          ],
          initialRoute: Routes.home,
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  GetPage<dynamic> _getPage(String routeName, page, [bool opaque = true]) =>
      GetPage(name: routeName, page: () => page, opaque: opaque);
}
