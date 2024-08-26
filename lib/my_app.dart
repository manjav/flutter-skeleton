import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'app_export.dart';

class MyApp extends StatefulWidget {
  static late final DateTime startTime;
  const MyApp({super.key});

  static final _observer =
      FirebaseAnalyticsObserver(analytics: FirebaseTracker.instance);

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
      // serviceLocator<Sounds>().playMusic();
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
          navigatorObservers: [MyApp._observer, SmartlookObserver()],
          theme: Themes.darkData,
          supportedLocales: Localization.locales,
          locale:
              Localization.locales.firstWhere((l) => l.languageCode == "en"),
          getPages: [
            _getPage(Routes.web, WebScreen()),
            _getPage(Routes.home, HomeScreen()),
            _getPage(Routes.chat, ChatScreen()),
            // _getPage(Routes.word, LessonWordScreen()),
            // _getPage(Routes.match, LessonMatchScreen()),
            // _getPage(Routes.dictation, LessonDictationScreen()),
            _getPage(Routes.lesson, LessonScreen()),
            _getPage(Routes.series, SeriesScreen()),
            _getPage(Routes.onboarding, OnboardingScreen()),
            _getPage(Routes.popupResult, ResultScreen()),
            _getPage(Routes.popupMessage, const MessagePopup()),
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

  GetPage<dynamic> _getPage(
    String routeName,
    page, [
    bool opaque = true,
    Transition transition = Transition.noTransition,
  ]) =>
      GetPage(
        name: routeName,
        page: () => page,
        opaque: opaque,
        transition: transition,
      );
}
