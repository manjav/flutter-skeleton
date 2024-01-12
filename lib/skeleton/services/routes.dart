import 'package:flutter/material.dart';

import '../../view/popups/building_mine_popup.dart';
import '../../view/popups/building_supportive_popup.dart';
import '../../view/popups/building_treasury_popup.dart';
import '../../view/popups/card_collection_popup.dart';
import '../../view/popups/card_details_popup.dart';
import '../../view/popups/card_enhance_popup.dart';
import '../../view/popups/card_evolve_popup.dart';
import '../../view/popups/card_select_category_popup.dart';
import '../../view/popups/card_select_popup.dart';
import '../../view/popups/card_select_type_popup.dart';
import '../../view/popups/combo_popup.dart';
import '../../view/popups/daily_gift_popup.dart';
import '../../view/popups/gift_popup.dart';
import '../../view/popups/hero_evolve_popup.dart';
import '../../view/popups/hero_popup.dart';
import '../../view/popups/invite_popup.dart';
import '../../view/popups/league_popup.dart';
import '../../view/popups/opponents_popup.dart';
import '../../view/popups/potion_popup.dart';
import '../../view/popups/profile_avatars_popup.dart';
import '../../view/popups/profile_edit_popup.dart';
import '../../view/popups/profile_popup.dart';
import '../../view/popups/ranking_popup.dart';
import '../../view/popups/restore_popup.dart';
import '../../view/popups/tribe_details_popup.dart';
import '../../view/popups/tribe_donate_popup.dart';
import '../../view/popups/tribe_edit_popup.dart';
import '../../view/popups/tribe_invite_popup.dart';
import '../../view/screens/screen_attack_outcome.dart';
import '../../view/screens/screen_deck.dart';
import '../../view/screens/screen_home.dart';
import '../../view/screens/screen_livebattle.dart';
import '../../view/screens/screen_livebattle_outcome.dart';
import '../../view/screens/screen_quest.dart';
import '../views/popups/inbox_popup.dart';
import '../views/popups/message_popup.dart';
import '../views/popups/settings_popup.dart';
import '../views/screens/loading_screen.dart';

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

  popupNone,
  popupMessage,
  popupCardDetails,
  popupCardEnhance,
  popupHeroEvolve,
  popupCardEvolve,
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
  popupProfileEdit,
  popupProfileAvatars,
  popupSettings,
  popupRestore,
  popupInvite,
  popupRedeemGift,
  popupDailyGift,
  popupTribeSearch,
  popupTribeOptions,
  popupTribeInvite,
  popupTribeEdit,
  popupTribeDonate,
  popupCardSelectType,
  popupCardSelectCategory,
}

extension RoutesExtension on Routes {
  static Widget getWidget(String routeName, {Map<String, dynamic>? args}) {
    return switch (routeName) {
      "/home" => HomeScreen(),
      "/deck" => DeckScreen(opponent: args?['opponent']),
      "/quest" => QuestScreen(args: args ?? {}),
      "/questOut" => AttackOutScreen(Routes.questOut, args: args ?? {}),
      "/battleOut" => AttackOutScreen(Routes.battleOut, args: args ?? {}),
      "/livebattleOut" => LiveOutScreen(args: args ?? {}),
      "/livebattle" => LiveBattleScreen(args: args ?? {}),
      "/popupCardDetails" => CardDetailsPopup(args: args ?? {}),
      "/popupCardEnhance" => CardEnhancePopup(args: args ?? {}),
      "/popupCardEvolve" => CardEvolvePopup(args: args ?? {}),
      "/popupHeroEvolve" => HeroEvolvePopup(args: args ?? {}),
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
      "/popupProfileEdit" => ProfileEditPopup(),
      "/popupProfileAvatars" => ProfileAvatarsPopup(),
      "/popupSettings" => SettingsPopup(),
      "/popupRestore" => RestorePopup(args: args ?? {}),
      "/popupInvite" => InvitePopup(),
      "/popupRedeemGift" => RedeemGiftPopup(),
      "/popupDailyGift" => DailyGiftPopup(),
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
      "/popupProfileEdit" ||
      "/popupProfileAvatars" ||
      "/popupRestore" ||
      "/popupInvite" ||
      "/popupRedeemGift" ||
      "/popupDailyGift" ||
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

  dynamic navigate(BuildContext context, {Map<String, dynamic>? args}) async {
    return await Navigator.pushNamed(context, routeName, arguments: args);
  }

  dynamic replace(BuildContext context, {Map<String, dynamic>? args}) async {
    return await Navigator.pushReplacementNamed(context, routeName,
        arguments: args);
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
