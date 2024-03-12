import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_export.dart';

void main() async {
  MyApp.startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // await Firebase.initializeApp();
  await Prefs().initialize();

  initServices();

  runApp(const MyApp());
}