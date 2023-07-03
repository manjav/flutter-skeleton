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
  static Widget getScreen(String routeName, {List<Object>? args}) {
    return switch (routeName) {
      "/home" => HomeScreen(),
      "/popupTabPage" =>
        const TabPagePopup(Routes.popupTabPage, args: {'tabsCount': 3}),
      _ => LoadingScreen(),
    };
  }

  String get routeName => "/$name";
}
