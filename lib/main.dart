import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/services_bloc.dart';
import 'services/core/integrated_services.dart';
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

  static final _firebaseAnalytics = FirebaseAnalytics.instance;
  static final _observer =
      FirebaseAnalyticsObserver(analytics: _firebaseAnalytics);

  static final IntegratedServices _integratedServices =
      IntegratedServices(firebaseAnalytics: _firebaseAnalytics);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              ServicesBloc(integratedServices: _integratedServices),
        ),
      ],
      child: MaterialApp(
          home: const LoadingScreen(), navigatorObservers: [_observer]),
    );
  }
}
