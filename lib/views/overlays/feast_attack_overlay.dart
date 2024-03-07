import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  Account? _account;
  Opponent? _opponent;
  Map<String, dynamic> _outcomeData = {};
  final Map<String, ImageAsset> _imageAssets = {};
  final List<AccountCard> _playerCards = [], _oppositeCards = [];
  SMIInput<double>? _playerCardsCount, _oppositeCardsCount;
  final Map<int, SMIInput<double>?> _cardPowers = {};
  bool _isBattle = false;

  @override
  void initState() {
    waitingSFX = "battle";
    super.initState();
    startSFX = "";
    _account = accountProvider.account;
    children = [animationBuilder("attack")];
    _opponent = widget.args["opponent"] ?? Opponent.create(1, "دشمن", 0);
    _isBattle = widget.args["isBattle"];
  }

  Future<void> getData() async {
    process(() async {
      SelectedCards? cards = widget.args["cards"];
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
        if (_isBattle) {
          params["opponent_id"] = _opponent!.id;
          params["attacks_in_today"] = _opponent!.todayAttacksCount;
        }
        _outcomeData =
            await rpc(_isBattle ? RpcId.battle : RpcId.quest, params: params);
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
        _outcomeData = jsonDecode(
            '{ "outcome":true, "won_by_chance":false, "gold":2843046, "gold_added":11, "league_bonus":4, "levelup_gold_added":0, "level":283, "xp":5373350, "xp_added":2, "rank":1, "tribe_rank":1, "attack_cards":[ { "id":586716, "last_used_at":1689592092, "power":366666, "base_card_id":310, "player_id":2775 }, { "id":586801, "last_used_at":1689592215, "power":55, "base_card_id":415, "player_id":2775 }, { "id":407570, "last_used_at":1689592018, "power":33323361, "base_card_id":335, "player_id":2775 }, { "id":586715, "last_used_at":1689592092, "power":366666, "base_card_id":310, "player_id":2775 }, { "id":587076, "last_used_at":1689592092, "power":352000, "base_card_id":316, "player_id":2775 } ], "opponent_cards":[ { "id":55962, "last_used_at":0, "power":302, "base_card_id":109, "player_id":3105 }, { "id":56021, "last_used_at":0, "power":214, "base_card_id":144, "player_id":3105 }, { "id":55746, "last_used_at":0, "power":204, "base_card_id":291, "player_id":3105 }, { "id":55747, "last_used_at":1543170902, "power":196, "base_card_id":235, "player_id":3105 } ], "tribe_gold":11861411, "gift_card":null, "attack_power":60215309, "def_power":916, "q":207850, "total_battles":479, "needs_captcha":false, "league_rank":5815, "league_id":24, "weekly_score":0, "score_added":0, "won_battle_num":537, "lost_battle_num":2750, "attack_bonus_power":25806561, "def_bonus_power":0, "tutorial_required_cards":null, "attacker_combo_info":[], "defender_combo_info":[], "potion_number":0, "nectar":50, "gift_potion":0, "gift_nectar":0, "available_combo_id_set":null, "purchase_deposits_to_bank":null, "attacker_hero_benefits_info":{ "cards":[ { "id":586716, "power":366666, "added_power":116666 }, { "id":407570, "power":33323361, "added_power":10602887 }, { "id":586715, "power":366666, "added_power":116666 }, { "id":587076, "power":352000, "added_power":112000 } ], "power_benefit":10948219, "gold_benefit":2, "cooldown_benefit":566 }, "defender_hero_benefits_info":[]}');
      }
      var playerCardsPower = 0;
      for (var card in _outcomeData["attack_cards"]) {
        _playerCards.add(AccountCard(_account!, card));
        playerCardsPower += Convert.toInt(card["power"]!);
      }
      _playerCards
          .sort((r, l) => (l.base.isHero ? -1 : 1) - (r.base.isHero ? -1 : 1));
      if (_outcomeData["attack_bonus_power"] > 0) {
        AccountCard cr =
            AccountCard(_account!, {"base_card_id": 103, "power": 400});
        cr.base.name = "TribeHelp";
        cr.power = Convert.toInt(_outcomeData["attack_bonus_power"]);
        cr.base.rarity = 0;
        cr.fruit.name = "TribeHelp";
        cr.base.fruit.category = 3;
        _playerCards.add(cr);
      }
      _playerCardsCount?.value = _playerCards.length.toDouble();

      if (!_isBattle) {
        _outcomeData["opponent_cards"] =
            _simulateOuestOppositeCards(playerCardsPower);
      }
      var oppositeCardsPower = 0;
      for (var card in _outcomeData["opponent_cards"] ?? []) {
        _oppositeCards.add(AccountCard(_account!, card));
        oppositeCardsPower += card["power"]! as int;
      }

      var remainingPower = (playerCardsPower - oppositeCardsPower).abs();
      var sidePower = _outcomeData["outcome"] ? remainingPower : 0;
      for (var i = _playerCards.length - 1; i >= 0; i--) {
        var power = sidePower.max(_playerCards[i].power);
        sidePower -= power;
        _cardPowers[i]?.value = power.min(0).toDouble();
      }
      sidePower = _outcomeData["outcome"] ? 0 : remainingPower;
      for (var i = _oppositeCards.length - 1; i >= 0; i--) {
        var power = sidePower.max(_oppositeCards[i].power);
        sidePower -= power;
        _cardPowers[i + 10]?.value = power.min(0).toDouble();
      }
      _outcomeData["opponent"] = _opponent;
      _oppositeCards
          .sort((r, l) => (l.base.isHero ? -1 : 1) - (r.base.isHero ? -1 : 1));
      if (_outcomeData["def_bonus_power"] > 0) {
        AccountCard cr =
            AccountCard(_account!, {"base_card_id": 103, "power": 400});
        cr.base.name = "TribeHelp";
        cr.power = Convert.toInt(_outcomeData["def_bonus_power"]);
        cr.base.rarity = 0;
        cr.fruit.name = "TribeHelp";
        cr.base.fruit.category = 3;
        _oppositeCards.add(cr);
      }
      _oppositeCardsCount?.value = _oppositeCards.length.toDouble();
      return _outcomeData;
    });
  }

  List _simulateOuestOppositeCards(int playerCardsPower) {
    var random = Random();
    var opponentPower = _opponent!.defPower;
    if (!_outcomeData["outcome"] && opponentPower < playerCardsPower) {
      opponentPower = playerCardsPower +
          (playerCardsPower * random.nextDouble() * 0.1).round();
    }
    var result = [];
    var cardPower = (opponentPower / 4).floor();
    var cards = _account!.loadingData.baseCards.values
        .where(
            (c) => c.power < cardPower && c.powerLimit > cardPower && !c.isHero)
        .toList();

    for (var i = 0; i < 4; i++) {
      var cardId = cards[random.nextInt(cards.length)].id;
      if (i == 3) {
        result.add({"base_card_id": cardId, "power": opponentPower});
      } else {
        var power = cardPower -
            (random.nextDouble() * 0.1 * cardPower +
                    random.nextDouble() * 0.2 * cardPower)
                .round();
        opponentPower -= power;
        result.add({"base_card_id": cardId, "power": power});
      }
    }
    return result;
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    _playerCardsCount = controller.findInput<double>("playerCards");
    _oppositeCardsCount = controller.findInput<double>("opponentCards");
    for (var i = 0; i < 5; i++) {
      _cardPowers[i] = controller.findInput<double>("cardPower$i");
      _cardPowers[i + 10] = controller.findInput<double>("cardPower${i + 10}");
    }
    updateRiveText("playerNameText", "you_l".l());
    updateRiveText("opponentNameText", _opponent!.name);
    artboard.addController(controller);
    getData();
    return controller;
  }

  @override
  Widget closeButton() {
    return const SizedBox();
  }

  @override
  void onRiveEvent(RiveEvent event) async {
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
    } else if (state == RewardAnimationState.shown) {
      await Future.delayed(const Duration(milliseconds: 10));
      var route = _opponent!.id != 0 ? Routes.battleOut : Routes.questOut;
      // ignore: use_build_context_synchronously
      Overlays.insert(
        context,
        AttackOutcomeFeastOverlay(
          args: _outcomeData,
          type: route,
          onClose: (data) async {
            onRiveEvent(const RiveEvent(
                name: "closing", secondsDelay: 0, properties: {}));
            closeInput?.value = true;
            closeButtonController?.reverse();
          },
        ),
      );
      // ignore: use_build_context_synchronously
      accountProvider.update(context, _outcomeData);
    } else if (state == RewardAnimationState.closing) {
      var lastRoute = _opponent!.id == 0 ? Routes.quest : Routes.popupOpponents;
      serviceLocator<RouteService>()
          .popUntil((route) => route.settings.name == lastRoute);
    }
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "playerAvatar") {
        asset.image = await loadImage("avatar_${_account!.avatarId}",
            subFolder: "avatars");
        return true;
      } else if (asset.name == "opponentAvatar") {
        asset.image = await loadImage("avatar_${_opponent!.avatarId}",
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
  void onScreenTouched() {
    if (state == RewardAnimationState.started) {
      skipInput?.value = true;
    }
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
