import 'package:flutter/material.dart';

import 'views.dart';

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
