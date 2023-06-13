import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/view/screens/iscreen.dart';
import 'blocs/services_bloc.dart';
import 'services/theme.dart';

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

  static final _firebaseAnalytics = FirebaseAnalytics.instance;
  static final _observer =
      FirebaseAnalyticsObserver(analytics: _firebaseAnalytics);

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
        key: key,
        child: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) =>
                      ServicesBloc(firebaseAnalytics: _firebaseAnalytics)),
            ],
            child: MaterialApp(
                navigatorObservers: [_observer],

                // Provide the generated AppLocalizations to the MaterialApp. This
                // allows descendant Widgets to display the correct translations
                // depending on the user's locale.
                /* localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
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
                      builder: (BuildContext context) => ScreenTools.getScreen(
                          routeSettings.name!,
                          args: routeSettings.arguments as List<Object>?));
                })));
  }
}
