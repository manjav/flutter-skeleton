import 'package:flutter/material.dart';
import '../../view/popups/building_war_popup.dart';

import 'popups/card_details_popup.dart';
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
  popupOpponents,
  popupBuildingWar,
}

extension RouteProvider on Routes {
  static Widget getWidget(String routeName, {Map<String, dynamic>? args}) {
    return switch (routeName) {
      "/deck" => DeckScreen(opponent: args?['opponent']),
      "/questOutcome" => FightOutcomeScreen(Routes.questOutcome, args ?? {}),
      "/battleOutcome" => FightOutcomeScreen(Routes.battleOutcome, args ?? {}),
      "/home" => HomeScreen(),
      "/popupCard" => CardDetailsPopup(args: args ?? {}),
      "/popupMessage" => MessagePopup(args: args ?? {}),
      "/popupTabPage" => TabPagePopup(args: args ?? {}),
      "/popupOpponents" => OpponentsPopup(args: args ?? {}),
      "/popupBuildingWar" => CardBuildingPopup(args: args ?? {}),
      _ => LoadingScreen(),
    };
  }

  String get routeName => "/$name";

  static bool getOpaque(String routeName) {
    return switch (routeName) {
      "/popupNone" ||
      "/popupCard" ||
      "/popupMessage" ||
      "/popupTabPage" ||
      "/popupOpponents" ||
      "/popupBuildingWar" =>
        false,
      _ => true,
    };
  }
}

class MaterialTransparentRoute<T> extends PageRoute<T>
    with MaterialRouteTransitionMixin<T> {
  final bool isOpaque;

  MaterialTransparentRoute({
    required this.builder,
    required RouteSettings settings,
    this.isOpaque = true,
    this.maintainState = true,
    bool fullscreenDialog = true,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  bool get opaque => isOpaque;

  @override
  final bool maintainState;

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}
