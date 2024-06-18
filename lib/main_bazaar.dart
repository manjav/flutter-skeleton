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

  FlavorConfig(name: "bazaar", variables: {
    "storePackageName": "com.farsitel.bazaar",
    "bindUrl": "ir.cafebazaar.pardakht.InAppBillingService.BIND",
    "storeId": "4",
    "updateUrl":
        "https://cafebazaar.ir/app/com.tcg.fruitcraft.trading.card.game.battle"
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
