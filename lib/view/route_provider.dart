import 'package:flutter/material.dart';

import '../../view/popups/card_popup.dart';
import '../../view/popups/message_popup.dart';
import '../../view/screens/deck_screen.dart';
import '../../view/screens/fight_outcome_scrren.dart';
import 'popups/tab_page_popup.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';

enum Routes {
  none,
  deck,
  questOutcome,
  battleOutcome,
  home,
  loading,
  profile,
  settings,
  shop,

  popupNone,
  popupCard,
  popupMessage,
  popupTabPage,
}

extension RouteProvider on Routes {
  static Widget getWidget(String routeName, {Map<String, dynamic>? args}) {
    return switch (routeName) {
      "/deck" => DeckScreen(),
      "/questOutcome" => FightOutcomeScreen(Routes.questOutcome, args ?? {}),
      "/battleOutcome" => FightOutcomeScreen(Routes.battleOutcome, args ?? {}),
      "/home" => HomeScreen(),
      "/popupCard" => CardDetailsPopup(args: args ?? {}),
      "/popupMessage" => MessagePopup(args: args ?? {}),
      "/popupTabPage" => TabPagePopup(args: args ?? {}),
      _ => LoadingScreen(),
    };
  }

  String get routeName => "/$name";
}
