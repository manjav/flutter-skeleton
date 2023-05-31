import 'package:flutter/material.dart';

import 'core/iservices.dart';

abstract class ThemeService extends IService {}

class MyTheme implements ThemeService {
  @override
  initialize({List<Object>? args}) {
    debugPrint("Analytics init");
  }

  @override
  log(log) {
    debugPrint("Analytics init");
  }
}
