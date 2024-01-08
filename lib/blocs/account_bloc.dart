import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/core/fruit.dart';
import '../../data/core/store.dart';
import '../../services/connection/http_connection.dart';
import '../data/core/account.dart';
import '../data/core/rpc.dart';
import '../data/core/tribe.dart';
import '../mixins/service_provider.dart';
import '../view/widgets/card_holder.dart';

class AccountEvent {}

class AccountInitEvent extends AccountEvent {
  AccountInitEvent();
}

class SetAccount extends AccountEvent {
  Account account;
  SetAccount({required this.account});
}

//--------------------------------------------------------

abstract class AccountState {
  final Account account;
  AccountState({required this.account});
}

class AccountInit extends AccountState {
  AccountInit({required super.account});
}

class AccountUpdate extends AccountState {
  AccountUpdate({required super.account});
}

//--------------------------------------------------------

class AccountBloc extends Bloc<AccountEvent, AccountState>
    with ServiceProvider {
  late Account? account;

  AccountBloc() : super(AccountInit(account: Account())) {
    on<SetAccount>(setAccount);
  }

  setAccount(SetAccount event, Emitter<AccountState> emit) {
    account = event.account;
    emit(AccountUpdate(account: account!));
  }

  Future<AccountCard?> evolve(
      BuildContext context, SelectedCards selectedCards) async {
    if (selectedCards.value.length < 2) return null;
    var params = {RpcParams.sacrifices.name: selectedCards.getIds()};
    var result = await getService<HttpConnection>(context)
        .rpc(RpcId.evolveCard, params: params);
    for (var card in selectedCards.value) {
      account!.cards.remove(card!.id);
    }
    if (context.mounted) {
      account!.update(context, result);
      add(SetAccount(account: account!));
    }
    return result["card"];
  }

  Future<AccountCard> evolveHero(
      BuildContext context, AccountCard heroCard) async {
    var result = await getService<HttpConnection>(context).rpc(RpcId.evolveCard,
        params: {RpcParams.sacrifices.name: "[${heroCard.id}]"});

    account!.cards.remove(heroCard.id);
    if (context.mounted) {
      account!.update(context, result);
    }
    // Replace hero
    AccountCard card = result["card"];
    var newHero = HeroCard(card, 0);
    newHero.items = account!.heroes[heroCard.id]!.items;
    account!.heroes[card.id] = newHero;
    add(SetAccount(account: account!));
    return newHero.card;
  }

  Future<AccountCard> enhanceMax(BuildContext context, AccountCard card) async {
    var result = await getService<HttpConnection>(context)
        .rpc(RpcId.enhanceMax, params: {RpcParams.card_id.name: card.id});
    if (context.mounted) {
      account!.update(context, result);
      add(SetAccount(account: account!));
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
      account!.cards.remove(card!.id);
    }
    if (context.mounted) {
      account!.update(context, result);
      add(SetAccount(account: account!));
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
        cards.add(AccountCard(account!, {"base_card_id": heroId}));
      }
      return cards;
    }
    result["achieveCards"] = result["cards"];
    result.remove("cards");
    if (context.mounted) {
      account!.update(context, result);
      add(SetAccount(account: account!));
    }
    return result["achieveCards"];
  }

  upgrade(BuildContext context, int id, {Tribe? tribe}) async {
    var params = {RpcParams.type.name: id};
    if (tribe != null) {
      params[RpcParams.tribe_id.name] = tribe.id;
    }
    var result = await getService<HttpConnection>(context).rpc(
        tribe != null ? RpcId.tribeUpgrade : RpcId.upgrade,
        params: params);

    if (context.mounted) {
      account!.update(context, result);
      add(SetAccount(account: account!));
    }
    return result;
  }
}
