import 'package:flutter/material.dart';

import 'popups/building_mine_popup.dart';
import 'popups/building_supportive_popup.dart';
import 'popups/building_treasury_popup.dart';
import 'popups/card_collection_popup.dart';
import 'popups/card_details_popup.dart';
import 'popups/card_enhance_popup.dart';
import 'popups/card_merge_popup.dart';
import 'popups/card_select_category_popup.dart';
import 'popups/card_select_popup.dart';
import 'popups/card_select_type_popup.dart';
import 'popups/card_upgrade_popup.dart';
import 'popups/combo_popup.dart';
import 'popups/gift_popup.dart';
import 'popups/hero_popup.dart';
import 'popups/inbox_popup.dart';
import 'popups/invite_popup.dart';
import 'popups/league_popup.dart';
import 'popups/message_popup.dart';
import 'popups/opponents_popup.dart';
import 'popups/potion_popup.dart';
import 'popups/profile_popup.dart';
import 'popups/ranking_popup.dart';
import 'popups/restore_popup.dart';
import 'popups/settings_popup.dart';
import 'popups/tribe_details_popup.dart';
import 'popups/tribe_donate_popup.dart';
import 'popups/tribe_edit_popup.dart';
import 'popups/tribe_invite_popup.dart';
import 'screens/deck_screen.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/screen_attack_outcome.dart';
import 'screens/screen_livebattle.dart';
import 'screens/screen_livebattle_outcome.dart';
import 'screens/screen_open_pack.dart';

enum Routes {
  none,
  deck,
  quest,
  questOut,
  battleOut,
  livebattleOut,
  home,
  loading,
  livebattle,
  openPack,

  popupNone,
  popupMessage,
  popupCardDetails,
  popupCardEnhance,
  popupCardUpgrade,
  popupCardMerge,
  popupCollection,
  popupCardSelect,
  popupLeague,
  popupRanking,
  popupOpponents,
  popupSupportiveBuilding,
  popupMineBuilding,
  popupTreasuryBuilding,
  popupPotion,
  popupCombo,
  popupHero,
  popupInbox,
  popupProfile,
  popupSettings,
  popupRestore,
  popupInvite,
  popupRedeemGift,
  popupTribeSearch,
  popupTribeOptions,
  popupTribeInvite,
  popupTribeEdit,
  popupTribeDonate,
  popupCardSelectType,
  popupCardSelectCategory,
}

extension RouteProvider on Routes {
  static Widget getWidget(String routeName, {Map<String, dynamic>? args}) {
    return switch (routeName) {
      "/home" => HomeScreen(),
      "/deck" => DeckScreen(opponent: args?['opponent']),
      "/quest" => QuestScreen(args: args ?? {}),
      "/questOut" => AttackOutScreen(Routes.questOut, args: args ?? {}),
      "/battleOut" => AttackOutScreen(Routes.battleOut, args: args ?? {}),
      "/livebattleOut" => LiveOutScreen(args: args ?? {}),
      "/livebattle" => LiveBattleScreen(args: args ?? {}),
      "/openPack" => OpenPackScreen(args: args ?? {}),
      "/popupCardDetails" => CardDetailsPopup(args: args ?? {}),
      "/popupCardEnhance" => CardEnhancePopup(args: args ?? {}),
      "/popupCardMerge" => CardMergePopup(args: args ?? {}),
      "/popupCardUpgrade" => CardUpgradePopup(args: args ?? {}),
      "/popupCollection" => CollectionPopup(),
      "/popupCardSelect" => CardSelectPopup(args: args ?? {}),
      "/popupMessage" => MessagePopup(args: args ?? {}),
      "/popupLeague" => LeaguePopup(),
      "/popupRanking" => RankingPopup(),
      "/popupOpponents" => OpponentsPopup(),
      "/popupSupportiveBuilding" => SupportiveBuildingPopup(args: args ?? {}),
      "/popupMineBuilding" => MineBuildingPopup(args: args ?? {}),
      "/popupTreasuryBuilding" => TreasuryBuildingPopup(args: args ?? {}),
      "/popupPotion" => PotionPopup(),
      "/popupCombo" => ComboPopup(),
      "/popupHero" => HeroPopup(args?["card"] as int),
      "/popupInbox" => InboxPopup(),
      "/popupProfile" => ProfilePopup(args?["id"] ?? -1),
      "/popupSettings" => SettingsPopup(),
      "/popupRestore" => RestorePopup(),
      "/popupInvite" => InvitePopup(),
      "/popupRedeemGift" => RedeemGiftPopup(),
      "/popupTribeOptions" => TribeDetailsPopup(args: args ?? {}),
      "/popupTribeInvite" => TribeInvitePopup(),
      "/popupTribeEdit" => TribeEditPopup(),
      "/popupTribeDonate" => TribeDonatePopup(),
      "/popupCardSelectType" => SelectCardTypePopup(),
      "/popupCardSelectCategory" => SelectCardCategoryPopup(),
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
      "/popupInbox" ||
      "/popupSettings" ||
      "/popupProfile" ||
      "/popupRestore" ||
      "/popupInvite" ||
      "/popupRedeemGift" ||
      "/popupMineBuilding" ||
      "/popupTribeOptions" ||
      "/popupTribeEdit" ||
      "/popupTribeDonate" ||
      "/popupTribeInvite" ||
      "/popupCardSelectType" ||
      "/popupCardSelectCategory" =>
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
    required RouteSettings super.settings,
    this.isOpaque = true,
    this.maintainState = true,
    super.fullscreenDialog = true,
  });

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
