import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/core/ranking.dart';
import '../../services/deviceinfo.dart';
import '../../services/sounds.dart';
import 'blocs/account_bloc.dart';
import 'blocs/services_bloc.dart';
import 'services/theme.dart';
import 'view/route_provider.dart';
import 'view/widgets/loaderwidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
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
      // BlocProvider.of<Services>(context).get<Sounds>().stopAll();
    } else if (state == AppLifecycleState.resumed) {
      BlocProvider.of<ServicesBloc>(context).get<Sounds>().playMusic();
    }
  }

  void restartApp() {
    Ranks.lists.clear();
    LoaderWidget.cacshedLoders.clear();
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
            ],
            child: MaterialApp(
                navigatorObservers: [MyApp._observer],

                // Provide the generated AppLocalizations to the MaterialApp. This
                // allows descendant Widgets to display the correct translations
                // depending on the user's locale.
                /* localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', ''), // English, no country code
                ], */

                // Use AppLocalizations to configure the correct application title
                // depending on the user's locale.
                //
                // The appTitle is defined in .arb files found in the localization
                // directory.
                /* onGenerateTitle: (BuildContext context) =>
                    AppLocalizations.of(context)!.appTitle, */

                // Define a light and dark color theme. Then, read the user's
                // preferred ThemeMode (light, dark, or system default) from the
                // SettingsController to display the correct theme.
                theme: Themes.darkData,
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
