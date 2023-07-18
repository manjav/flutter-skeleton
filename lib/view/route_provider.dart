import 'package:flutter/material.dart';

import 'popups/card_popup.dart';
import 'popups/message_popup.dart';
import 'popups/opponents_popup.dart';
import 'popups/tab_page_popup.dart';
import 'screens/deck_screen.dart';
import 'screens/fight_outcome_screen.dart';
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
  popupOpponents
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
      "/popupOpponents" => OpponentsPopup(args: args ?? {}),
      _ => LoadingScreen(),
    };
  }

  String get routeName => "/$name";
}
