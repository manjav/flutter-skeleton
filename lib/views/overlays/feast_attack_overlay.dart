import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class AttackFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;

  const AttackFeastOverlay({required this.args, super.onClose, super.key})
      : super(route: OverlaysName.feastAttack);

  @override
  createState() => _AttackFeastOverlayState();
}

class _AttackFeastOverlayState extends AbstractOverlayState<AttackFeastOverlay>
    with RewardScreenMixin {
  late Account _account;
  late Opponent _opponent;
  Map<String, dynamic> _outcomeData = {};
  final Map<String, ImageAsset> _imageAssets = {};
  final List<AccountCard> _playerCards = [], _oppositeCards = [];
  SMIInput<double>? _playerCardsCount, _oppositeCardsCount;

  @override
  void initState() {
    super.initState();
    waitingSFX = "attack";
    _account = accountProvider.account;
    children = [animationBuilder("attack")];
    _opponent = widget.args["opponent"] ?? Opponent.create(1, "دشمن", 0);

    process(() async {
      SelectedCards? cards = widget.args["cards"];
      var isBattle = widget.args["opponent"] != null;
      if (cards != null) {
        var params = {
          "cards": cards.getIds(),
          "check": md5
              .convert(utf8.encode("${accountProvider.account.q}"))
              .toString()
        };
        if (cards.value[2] != null) {
          params["hero_id"] = cards.value[2]!.id;
        }
        if (isBattle) {
          params["opponent_id"] = _opponent.id;
          params["attacks_in_today"] = _opponent.todayAttacksCount;
        }
        _outcomeData =
            await rpc(isBattle ? RpcId.battle : RpcId.quest, params: params);
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
        _outcomeData = jsonDecode(
            '{ "outcome":true, "won_by_chance":false, "gold":2843046, "gold_added":11, "league_bonus":4, "levelup_gold_added":0, "level":283, "xp":5373350, "xp_added":2, "rank":1, "tribe_rank":1, "attack_cards":[ { "id":586716, "last_used_at":1689592092, "power":366666, "base_card_id":310, "player_id":2775 }, { "id":586801, "last_used_at":1689592215, "power":55, "base_card_id":415, "player_id":2775 }, { "id":407570, "last_used_at":1689592018, "power":33323361, "base_card_id":335, "player_id":2775 }, { "id":586715, "last_used_at":1689592092, "power":366666, "base_card_id":310, "player_id":2775 }, { "id":587076, "last_used_at":1689592092, "power":352000, "base_card_id":316, "player_id":2775 } ], "opponent_cards":[ { "id":55962, "last_used_at":0, "power":302, "base_card_id":109, "player_id":3105 }, { "id":56021, "last_used_at":0, "power":214, "base_card_id":144, "player_id":3105 }, { "id":55746, "last_used_at":0, "power":204, "base_card_id":291, "player_id":3105 }, { "id":55747, "last_used_at":1543170902, "power":196, "base_card_id":235, "player_id":3105 } ], "tribe_gold":11861411, "gift_card":null, "attack_power":60215309, "def_power":916, "q":207850, "total_battles":479, "needs_captcha":false, "league_rank":5815, "league_id":24, "weekly_score":0, "score_added":0, "won_battle_num":537, "lost_battle_num":2750, "attack_bonus_power":25806561, "def_bonus_power":0, "tutorial_required_cards":null, "attacker_combo_info":[], "defender_combo_info":[], "potion_number":0, "nectar":50, "gift_potion":0, "gift_nectar":0, "available_combo_id_set":null, "purchase_deposits_to_bank":null, "attacker_hero_benefits_info":{ "cards":[ { "id":586716, "power":366666, "added_power":116666 }, { "id":407570, "power":33323361, "added_power":10602887 }, { "id":586715, "power":366666, "added_power":116666 }, { "id":587076, "power":352000, "added_power":112000 } ], "power_benefit":10948219, "gold_benefit":2, "cooldown_benefit":566 }, "defender_hero_benefits_info":[]}');
      }
      for (var card in _outcomeData["attack_cards"]) {
        _playerCards.add(AccountCard(_account, card));
      }
      _playerCards
          .sort((r, l) => (l.base.isHero ? -1 : 1) - (r.base.isHero ? -1 : 1));
      _playerCardsCount?.value = _playerCards.length.toDouble();

      for (var card in _outcomeData["opponent_cards"] ?? []) {
        _oppositeCards.add(AccountCard(_account, card));
      }
      _oppositeCards
          .sort((r, l) => (l.base.isHero ? -1 : 1) - (r.base.isHero ? -1 : 1));
      _oppositeCardsCount?.value = _oppositeCards.length.toDouble();
      return _outcomeData;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    _playerCardsCount = controller.findInput<double>("playerCards");
    _oppositeCardsCount = controller.findInput<double>("opponentCards");
    updateRiveText("playerNameText", "you_l".l());
    updateRiveText("opponentNameText", _opponent.name);
    artboard.addController(controller);
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAnimationState.started) {
      updateCard(i, AccountCard card) {
        updateRiveText("cardNameText$i", "${card.base.fruit.name}_title".l());
        updateRiveText("cardLevelText$i", card.base.rarity.convert());
        updateRiveText("cardPowerText$i", "ˢ${card.power.compact()}");
        loadCardIcon(_imageAssets["cardIcon$i"]!, card.base.getName());
        loadCardFrame(_imageAssets["cardFrame$i"]!, card.base);
      }

      for (var i = 0; i < _playerCards.length; i++) {
        updateCard(i, _playerCards[i]);
      }
      for (var i = 0; i < _oppositeCards.length; i++) {
        updateCard(10 + i, _oppositeCards[i]);
      }
    } else if (state == RewardAnimationState.closing) {
      var route =
          widget.args["opponent"] != null ? Routes.battleOut : Routes.questOut;
      context
          .read<ServicesProvider>()
          .get<RouteService>()
          .to(route, args: _outcomeData);
    }
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "playerAvatar") {
        asset.image = await loadImage("avatar_${_account.avatarId}",
            subFolder: "avatars");
        return true;
      } else if (asset.name == "opponentAvatar") {
        asset.image = await loadImage("avatar_${_opponent.avatarId}",
            subFolder: "avatars");
        return true;
      } else if (asset.name.startsWith("card")) {
        _imageAssets[asset.name] = asset;
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }

  @override
  Future<void> dismiss() async {
    await Future.delayed(const Duration(seconds: 1));
    widget.onClose?.call(result);
    if (state.index < RewardAnimationState.disposed.index) {
      Overlays.remove(widget.route);
      state = RewardAnimationState.disposed;
    }
  }
}
