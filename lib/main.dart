import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'app_export.dart';

void main() async {
  MyApp.startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  // await Firebase.initializeApp();
  await Prefs().initialize();

  initServices();
  runApp(const MyApp());
}
