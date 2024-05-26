import 'package:flutter/material.dart';

import '../app_export.dart';

class AccountProvider extends ChangeNotifier {
  late Account account;

  void initialize(Account account) => this.account = account;

  Map<String, dynamic>? update(
      [BuildContext? context, Map<String, dynamic>? data]) {
    Map<String, dynamic>? result;
    if (data != null) {
      result = account.update(context!, data);
    }
    updateBuildingsLevel();
    notifyListeners();
    return result;
  }

  void updateTutorial(BuildContext context, int index, int id) async {
    await serviceLocator<HttpConnection>().tryRpc(context, RpcId.tutorialState,
        params: {"index": index == 0 ? 1 : index, "id": id});
    account.tutorial_id = id;
    account.tutorial_index = index;
    notifyListeners();
  }

  ///Update buildings level after account level up
  void updateBuildingsLevel() {
    for (var building in account.buildings.values) {
      var isAvailable = building.getIsAvailable(account);
      if (!isAvailable) {
        building.level = 0;
      } else {
        if (building.level == 0) building.level = 1;
      }
    }
    notifyListeners();
  }

  void updateBuilding(Building building) {
    account.buildings[building.type] = building;
    notifyListeners();
  }

  void installTribe(dynamic data) {
    if (data == null) {
      serviceLocator<NoobSocket>().unsubscribe("tribe${account.tribe?.id}");
    }
    account.installTribe(data);
    if (account.tribe != null) {
      serviceLocator<NoobSocket>().subscribe("tribe${account.tribe?.id}");
    }
    notifyListeners();
  }

  Future<AccountCard?> evolve(
      BuildContext context, SelectedCards selectedCards) async {
    if (selectedCards.value.length < 2) return null;
    var params = {RpcParams.sacrifices.name: selectedCards.getIds()};
    var result = await serviceLocator<HttpConnection>()
        .rpc(RpcId.evolveCard, params: params);
    for (var card in selectedCards.value) {
      account.cards.remove(card!.id);
    }
    if (context.mounted) {
      update(context, result);
    }
    return result["card"];
  }

  Future<AccountCard> evolveHero(
      BuildContext context, AccountCard heroCard) async {
    var result = await serviceLocator<HttpConnection>().rpc(RpcId.evolveCard,
        params: {RpcParams.sacrifices.name: "[${heroCard.id}]"});

    account.cards.remove(heroCard.id);
    if (context.mounted) {
      update(context, result);
    }
    // Replace hero
    AccountCard card = result["card"];
    var newHero = HeroCard(card, 0);
    newHero.items = account.heroes[heroCard.id]!.items;
    account.heroes[card.id] = newHero;
    notifyListeners();
    return newHero.card;
  }

  Future<AccountCard> enhanceMax(BuildContext context, AccountCard card) async {
    var result = await serviceLocator<HttpConnection>()
        .rpc(RpcId.enhanceMax, params: {RpcParams.card_id.name: card.id});
    if (context.mounted) {
      update(context, result);
    }
    return result["card"];
  }

  Future<AccountCard> enhance(BuildContext context, AccountCard card,
      SelectedCards selectedCards) async {
    var params = {
      RpcParams.card_id.name: card.id,
      RpcParams.sacrifices.name: selectedCards.getIds()
    };
    var result = await serviceLocator<HttpConnection>()
        .rpc(RpcId.enhanceCard, params: params);
    for (var card in selectedCards.value) {
      account.cards.remove(card!.id);
    }
    if (context.mounted) {
      update(context, result);
    }
    return result["card"];
  }

  Future<List<AccountCard>> openPack(BuildContext context, ShopItem pack,
      {int selectedCardId = -1}) async {
    var params = {RpcParams.type.name: pack.id};
    if (selectedCardId > -1) {
      params["base_card_id"] = selectedCardId;
    }
    var result = await serviceLocator<HttpConnection>()
        .rpc(RpcId.buyCardPack, params: params);
    if (result.containsKey("base_card_id_set")) {
      var cards = <AccountCard>[];

      for (var heroId in result["base_card_id_set"]) {
        cards.add(AccountCard(account, {"base_card_id": heroId}));
      }
      return cards;
    }
    result["achieveCards"] = result["cards"];
    result.remove("cards");
    if (context.mounted) {
      update(context, result);
    }
    return result["achieveCards"];
  }

  Future<Map<String, dynamic>> boostPack(
      BuildContext context, ShopItem pack) async {
    var params = <String, dynamic>{RpcParams.type.name: pack.id};
    params["with_nectar"] = true;

    var result = await serviceLocator<HttpConnection>()
        .rpc(RpcId.buyBoostPack, params: params);

    if (context.mounted) {
      update(context, result);
    }
    return result["next_prices"];
  }

  upgrade(BuildContext context, Building building, {Tribe? tribe}) async {
    var id = building.type.id;
    var params = {RpcParams.type.name: id};
    if (tribe != null) {
      params[RpcParams.tribe_id.name] = tribe.id;
    }
    var result = await serviceLocator<HttpConnection>().rpc(
        tribe != null ? RpcId.tribeUpgrade : RpcId.upgrade,
        params: params);

    if (tribe != null) {
      tribe.levels[id] = result["level"];
    }
    building.level = result["level"];
    result.remove("level");
    if (context.mounted) {
      update(context, result);
    }
    return result;
  }
}
