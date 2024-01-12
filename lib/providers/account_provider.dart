import 'package:flutter/material.dart';

import '../../data/core/building.dart';
import '../../data/core/fruit.dart';
import '../../data/core/store.dart';
import '../../services/connection/http_connection.dart';
import '../data/core/account.dart';
import '../data/core/rpc.dart';
import '../data/core/tribe.dart';
import '../mixins/service_finder_mixin.dart';
import '../view/widgets/card_holder.dart';

class AccountProvider extends ChangeNotifier with ServiceFinderMixin {
  late Account account;

  void initialize(Account account) => this.account = account;

  Map<String, dynamic>? update(
      [BuildContext? context, Map<String, dynamic>? data]) {
    Map<String, dynamic>? result;
    if (data != null) {
      result = account.update(context!, data);
    }
    notifyListeners();
    return result;
  }

  void updateBuilding(Building building) {
    account.buildings[building.type] = building;
    notifyListeners();
  }

  void installTribe(dynamic data) {
    account.installTribe(data);
    notifyListeners();
  }

  Future<AccountCard?> evolve(
      BuildContext context, SelectedCards selectedCards) async {
    if (selectedCards.value.length < 2) return null;
    var params = {RpcParams.sacrifices.name: selectedCards.getIds()};
    var result = await getService<HttpConnection>(context)
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
    var result = await getService<HttpConnection>(context).rpc(RpcId.evolveCard,
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
    var result = await getService<HttpConnection>(context)
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
    var result = await getService<HttpConnection>(context)
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
    var result = await getService<HttpConnection>(context)
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

  upgrade(BuildContext context, Building building, {Tribe? tribe}) async {
    var id = building.type.id;
    var params = {RpcParams.type.name: id};
    if (tribe != null) {
      params[RpcParams.tribe_id.name] = tribe.id;
    }
    var result = await getService<HttpConnection>(context).rpc(
        tribe != null ? RpcId.tribeUpgrade : RpcId.upgrade,
        params: params);

    if (tribe != null) {
      building.level++;
      tribe.levels[id] = tribe.levels[id]! + 1;
    } else {
      building.level = result["level"];
    }
    if (context.mounted) {
      update(context, result);
    }
    return result;
  }
}
