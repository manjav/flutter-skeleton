import 'package:flutter/material.dart';
import '../../view/popups/card_popup.dart';
import '../../view/screens/deck_screen.dart';

import 'popups/tab_page_popup.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';

enum Routes {
  none,
  deck,
  home,
  loading,
  profile,
  settings,
  shop,

  popupNone,
  popupCard,
  popupTabPage,
}

extension RouteProvider on Routes {
  static Widget getWidget(String routeName, {Map<String, dynamic>? args}) {
    return switch (routeName) {
      "/deck" => DeckScreen(),
      "/home" => HomeScreen(),
      "/popupCard" => CardDetailsPopup(Routes.popupCard, args: args ?? {}),
      "/popupTabPage" => TabPagePopup(Routes.popupTabPage, args: args ?? {}),
      _ => LoadingScreen(),
    };
  }

  String get routeName => "/$name";
}
