import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/deviceinfo.dart';
import 'blocs/account_bloc.dart';
import 'blocs/services.dart';
import 'services/theme.dart';
import 'view/route_provider.dart';

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

class _MyAppState extends State<MyApp> {
  late UniqueKey key;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void restartApp() {
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
                  create: (context) =>
                      Services(firebaseAnalytics: MyApp._firebaseAnalytics)),
              BlocProvider(create: (context) => AccountBloc())
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
                  return MaterialPageRoute<void>(
                      settings: routeSettings,
                      builder: (BuildContext context) =>
                          RouteProvider.getWidget(routeSettings.name!,
                              args: routeSettings.arguments
                                  as Map<String, dynamic>?));
                })));
  }
}
