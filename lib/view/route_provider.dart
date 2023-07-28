import 'package:flutter/material.dart';

import 'popups/building_mine_popup.dart';
import 'popups/building_supportive_popup.dart';
import 'popups/building_treasury_popup.dart';
import 'popups/card_details_popup.dart';
import 'popups/card_enhance_popup.dart';
import 'popups/card_merge_popup.dart';
import 'popups/card_select_popup.dart';
import 'popups/message_popup.dart';
import 'popups/opponents_popup.dart';
import 'popups/league_popup.dart';
import 'popups/ranking_popup.dart';
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
  popupCardDetails,
  popupCardEnhance,
  popupCardMerge,
  popupCardSelect,
  popupMessage,
  popupLeague,
  popupRanking,
  popupOpponents,
  popupSupportiveBuilding,
  popupMineBuilding,
  popupTreasuryBuilding,
}

extension RouteProvider on Routes {
  static Widget getWidget(String routeName, {Map<String, dynamic>? args}) {
    return switch (routeName) {
      "/home" => HomeScreen(),
      "/deck" => DeckScreen(opponent: args?['opponent']),
      "/questOutcome" => FightOutcomeScreen(Routes.questOutcome, args ?? {}),
      "/battleOutcome" => FightOutcomeScreen(Routes.battleOutcome, args ?? {}),
      "/popupCardDetails" => CardDetailsPopup(args: args ?? {}),
      "/popupCardEnhance" => CardEnhancePopup(args: args ?? {}),
      "/popupCardMerge" => CardMergePopup(args: args ?? {}),
      "/popupCardSelect" => CardSelectPopup(args: args ?? {}),
      "/popupMessage" => MessagePopup(args: args ?? {}),
      "/popupLeague" => LeaguePopup(args: args ?? {}),
      "/popupRanking" => RankingPopup(args: args ?? {}),
      "/popupOpponents" => OpponentsPopup(args: args ?? {}),
      "/popupSupportiveBuilding" => SupportiveBuildingPopup(args: args ?? {}),
      "/popupMineBuilding" => MineBuildingPopup(args: args ?? {}),
      "/popupTreasuryBuilding" => TreasuryBuildingPopup(args: args ?? {}),
      _ => LoadingScreen(),
    };
  }

  String get routeName => "/$name";

  static bool getOpaque(String routeName) {
    return switch (routeName) {
      "/popupNone" ||
      "/popupCardDetails" ||
      "/popupCardSelect" ||
      "/popupMessage" ||
      "/popupLeague" ||
      "/popupOpponents" ||
      "/popupSupportiveBuilding" ||
      "/popupTreasuryBuilding" ||
      "/popupMineBuilding" =>
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
