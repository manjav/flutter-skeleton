import 'package:flutter/material.dart';

import 'popups/building_mine_popup.dart';
import 'popups/building_supportive_popup.dart';
import 'popups/building_treasury_popup.dart';
import 'popups/card_collection_popup.dart';
import 'popups/card_details_popup.dart';
import 'popups/card_enhance_popup.dart';
import 'popups/card_merge_popup.dart';
import 'popups/card_select_popup.dart';
import 'popups/combo_popup.dart';
import 'popups/gift_popup.dart';
import 'popups/hero_popup.dart';
import 'popups/invite_popup.dart';
import 'popups/league_popup.dart';
import 'popups/message_popup.dart';
import 'popups/opponents_popup.dart';
import 'popups/potion_popup.dart';
import 'popups/ranking_popup.dart';
import 'popups/restore_popup.dart';
import 'popups/settings_popup.dart';
import 'screens/deck_screen.dart';
import 'screens/fight_outcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/screen_livebattle.dart';
import 'screens/screen_open_pack.dart';

enum Routes {
  none,
  deck,
  questOutcome,
  battleOutcome,
  home,
  loading,
  livebattle,
  openPack,

  popupNone,
  popupCardDetails,
  popupCardEnhance,
  popupCardMerge,
  popupCollection,
  popupCardSelect,
  popupMessage,
  popupLeague,
  popupRanking,
  popupOpponents,
  popupSupportiveBuilding,
  popupMineBuilding,
  popupTreasuryBuilding,
  popupPotion,
  popupCombo,
  popupHero,
  popupSettings,
  popupRestore,
  popupInvite,
  popupRedeemGift,
}

extension RouteProvider on Routes {
  static Widget getWidget(String routeName, {Map<String, dynamic>? args}) {
    return switch (routeName) {
      "/home" => HomeScreen(),
      "/deck" => DeckScreen(opponent: args?['opponent']),
      "/questOutcome" => FightOutcomeScreen(Routes.questOutcome, args ?? {}),
      "/battleOutcome" => FightOutcomeScreen(Routes.battleOutcome, args ?? {}),
      "/openPack" => OpenPackScreen(args ?? {}),
      "/popupCardDetails" => CardDetailsPopup(args: args ?? {}),
      "/popupCardEnhance" => CardEnhancePopup(args: args ?? {}),
      "/popupCardMerge" => CardMergePopup(args: args ?? {}),
      "/popupCollection" => CollectionPopup(args: args ?? {}),
      "/popupCardSelect" => CardSelectPopup(args: args ?? {}),
      "/popupMessage" => MessagePopup(args: args ?? {}),
      "/popupLeague" => LeaguePopup(args: args ?? {}),
      "/popupRanking" => RankingPopup(args: args ?? {}),
      "/popupOpponents" => OpponentsPopup(args: args ?? {}),
      "/popupSupportiveBuilding" => SupportiveBuildingPopup(args: args ?? {}),
      "/popupMineBuilding" => MineBuildingPopup(args: args ?? {}),
      "/popupTreasuryBuilding" => TreasuryBuildingPopup(args: args ?? {}),
      "/popupPotion" => PotionPopup(args: args ?? {}),
      "/popupCombo" => ComboPopup(args: args ?? {}),
      "/popupHero" => HeroPopup(args: args ?? {}),
      "/popupSettings" => SettingsPopup(args: args ?? {}),
      "/popupRestore" => RestorePopup(args: args ?? {}),
      "/popupInvite" => InvitePopup(args: args ?? {}),
      "/popupRedeemGift" => RedeemGiftPopup(args: args ?? {}),
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
      "/popupPotion" ||
      "/popupCombo" ||
      "/popupHero" ||
      "/popupSettings" ||
      "/popupRestore" ||
      "/popupInvite" ||
      "/popupRedeemGift" ||
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
