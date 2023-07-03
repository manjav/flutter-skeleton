import 'package:flutter/material.dart';

import 'popups/tab_page_popup.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';

enum Routes {
  none,
  home,
  loading,
  profile,
  settings,
  shop,

  popupNone,
  popupTabPage
}

extension RouteProvider on Routes {
  static Widget getWidget(String routeName, {Map<String, dynamic>? args}) {
    return switch (routeName) {
      "/home" => HomeScreen(),
      "/popupTabPage" => TabPagePopup(Routes.popupTabPage, args: args ?? {}),
      _ => LoadingScreen(),
    };
  }

  String get routeName => "/$name";
}
