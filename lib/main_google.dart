import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import 'app_export.dart';

void main() async {
  MyApp.startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();

  FlavorConfig(name: "google", variables: {
    "storePackageName": "com.android.vending",
    "bindUrl": "com.android.vending.BILLING",
    "storeId": "3"
  });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp();
  await Prefs().initialize();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  initServices();

  runApp(const MyApp());
}