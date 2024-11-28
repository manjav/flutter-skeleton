import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifetalk/firebase_options.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app_export.dart';

void main() async {
  MyApp.startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  WakelockPlus.enable();
  await Prefs().initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _catchErrors();
  initServices();
  runApp(const MyApp());
}

void _catchErrors() {
  if (kDebugMode) {
    return;
  }
  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    // If you want to record a "non-fatal" exception
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };

  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    // If you want to record a "non-fatal" exception
    FirebaseCrashlytics.instance.recordError(error, stack);
    return true;
  };
}
