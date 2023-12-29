import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/account.dart';
import '../../data/core/adam.dart';
import '../../data/core/fruit.dart';
import '../../data/core/rpc.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/localization.dart';
import '../../utils/utils.dart';
import '../widgets/card_holder.dart';
import 'overlay.dart';

class AttackFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const AttackFeastOverlay({required this.args, super.onClose, super.key})
      : super(type: OverlayType.feastAttack);

  @override
  createState() => _AttackFeastOverlayState();
}

class _AttackFeastOverlayState extends AbstractOverlayState<AttackFeastOverlay>
    with RewardScreenMixin {
  late Account _account;
  late Opponent _opponent;
  final Map<String, ImageAsset> _imageAssets = {};
  final List<AccountCard> _playerCards = [], _oppositeCards = [];
  SMIInput<double>? _playerCardsCount, _oppositeCardsCount;

  @override
  void initState() {
    super.initState();
    _account = accountBloc.account!;
    children = [animationBuilder("attack")];
    _opponent = widget.args["opponent"] ?? Opponent.create(1, "دشمن", 0);

    process(() async {
      SelectedCards? cards = widget.args["cards"];
      var isBattle = widget.args.containsKey("opponent");
      Map<String, dynamic> data;
      if (cards != null) {
    var params = {
      "cards": cards.getIds(),
          "check":
              md5.convert(utf8.encode("${accountBloc.account!.q}")).toString()
    };
    if (cards.value[2] != null) {
          params["hero_id"] = cards.value[2]!.id;
    }
    if (isBattle) {
          params["opponent_id"] = _opponent.id;
          params["attacks_in_today"] = _opponent.todayAttacksCount;
    }
        data = await rpc(isBattle ? RpcId.battle : RpcId.quest, params: params);
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
        data = jsonDecode(
            '{ "outcome":true, "won_by_chance":false, "gold":2843046, "gold_added":11, "league_bonus":4, "levelup_gold_added":0, "level":283, "xp":5373350, "xp_added":2, "rank":1, "tribe_rank":1, "attack_cards":[ { "id":586716, "last_used_at":1689592092, "power":366666, "base_card_id":310, "player_id":2775 }, { "id":586801, "last_used_at":1689592215, "power":55, "base_card_id":415, "player_id":2775 }, { "id":407570, "last_used_at":1689592018, "power":33323361, "base_card_id":335, "player_id":2775 }, { "id":586715, "last_used_at":1689592092, "power":366666, "base_card_id":310, "player_id":2775 }, { "id":587076, "last_used_at":1689592092, "power":352000, "base_card_id":316, "player_id":2775 } ], "opponent_cards":[ { "id":55962, "last_used_at":0, "power":302, "base_card_id":109, "player_id":3105 }, { "id":56021, "last_used_at":0, "power":214, "base_card_id":144, "player_id":3105 }, { "id":55746, "last_used_at":0, "power":204, "base_card_id":291, "player_id":3105 }, { "id":55747, "last_used_at":1543170902, "power":196, "base_card_id":235, "player_id":3105 } ], "tribe_gold":11861411, "gift_card":null, "attack_power":60215309, "def_power":916, "q":207850, "total_battles":479, "needs_captcha":false, "league_rank":5815, "league_id":24, "weekly_score":0, "score_added":0, "won_battle_num":537, "lost_battle_num":2750, "attack_bonus_power":25806561, "def_bonus_power":0, "tutorial_required_cards":null, "attacker_combo_info":[], "defender_combo_info":[], "potion_number":0, "nectar":50, "gift_potion":0, "gift_nectar":0, "available_combo_id_set":null, "purchase_deposits_to_bank":null, "attacker_hero_benefits_info":{ "cards":[ { "id":586716, "power":366666, "added_power":116666 }, { "id":407570, "power":33323361, "added_power":10602887 }, { "id":586715, "power":366666, "added_power":116666 }, { "id":587076, "power":352000, "added_power":112000 } ], "power_benefit":10948219, "gold_benefit":2, "cooldown_benefit":566 }, "defender_hero_benefits_info":[]}');
      }
      for (var card in data["attack_cards"]) {
        _playerCards.add(AccountCard(_account, card));
      }
      _playerCards
          .sort((r, l) => (l.base.isHero ? -1 : 1) - (r.base.isHero ? -1 : 1));
      _playerCardsCount?.value = _playerCards.length.toDouble();

      for (var card in data["opponent_cards"]) {
        _oppositeCards.add(AccountCard(_account, card));
      }
      _oppositeCards
          .sort((r, l) => (l.base.isHero ? -1 : 1) - (r.base.isHero ? -1 : 1));
      _oppositeCardsCount?.value = _oppositeCards.length.toDouble();
      return data;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    for (var i = 1; i < 3; i++) {
      // updateRiveText(
      //     "cardNameText$i", "${_mergedCard.base.fruit.name}_title".l());
      // updateRiveText("cardLevelText$i", _mergedCard.base.rarity.convert());
      // updateRiveText("cardPowerText$i", "ˢ${_mergedCard.power.compact()}");
    }
    updateRiveText("titleText", "evolve_l".l());
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAnimationState.started) {
      // updateRiveText("cardNameText3", "${_newCard.base.fruit.name}_title".l());
      // updateRiveText("cardLevelText3", _newCard.base.rarity.convert());
      // updateRiveText("cardPowerText3", "ˢ${_newCard.power.compact()}");
      // super.loadCardIcon(_cardIconAsset!, _newCard.base.getName());
      // super.loadCardFrame(_cardBackgroundAsset!, _newCard.base);
    }
  }

  // @override
  // Future<void> loadCardIcon(ImageAsset asset, String name) async =>
  //     super.loadCardIcon(asset, _mergedCard.base.getName());

  // @override
  // Future<void> loadCardFrame(ImageAsset asset, FruitCard? card) async =>
  //     super.loadCardFrame(asset, _mergedCard.base);

  // @override
  // Future<bool> onRiveAssetLoad(
  //     FileAsset asset, Uint8List? embeddedBytes) async {
  //   if (asset is ImageAsset) {
  //     if (asset.name == "newCardIcon") {
  //       _cardIconAsset = asset;
  //       return true;
  //     } else if (asset.name == "newCardFrame") {
  //       _cardBackgroundAsset = asset;
  //       return true;
  //     }
  //   }
  //   return super.onRiveAssetLoad(asset, embeddedBytes);
  // }
}
