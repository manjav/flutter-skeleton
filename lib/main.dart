import 'package:flutter/material.dart';

import 'app_export.dart';

void main() async {
  MyApp.startTime = DateTime.now();
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Prefs().initialize();

  initServices();

  runApp(const MyApp());
}
