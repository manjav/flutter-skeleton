import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

class LiveBattleScreen extends AbstractScreen {
  static List<double> deadlines = [];

  LiveBattleScreen({super.key}) : super(Routes.liveBattle, closable: false);

  @override
  createState() => _LiveBattleScreenState();
}

class _LiveBattleScreenState extends AbstractScreenState<LiveBattleScreen> {
  late Account _account;
  late PageController _pageController;
  final Warriors _warriorsNotifier = Warriors();

  Map<int, LiveWarrior> get _warriors => _warriorsNotifier.value;
  final SelectedCards _deckCards = SelectedCards([]);
  final ValueNotifier<int> _powerBalance = ValueNotifier(0);
  final ValueNotifier<IntVec2d> _slotState = ValueNotifier(IntVec2d(0, 0));
  Timer? _timer;
  double _seconds = 0;
  int _maxPower = 0;
  bool _isDeckActive = true;
  int _battleId = 0, _helpCost = 0;
  late Opponent _friendsHead, _oppositesHead;

  @override
  List<Widget> appBarElementsLeft() => [];

  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _account = accountProvider.account;
    _battleId = widget.args["battle_id"] ?? 0;
    _helpCost = widget.args["help_cost"] ?? 33;
    if (widget.args.containsKey("created_at")) {
      _seconds = (_account.getTime() -
              _account.getTime(time: widget.args["created_at"]))
          .toDouble();
    }

    if (!isTutorial) {
      var socket = serviceLocator<NoobSocket>();
      if (!socket.isConnected) {
        socket.connect();
      }
      socket.onReceive.add(_onNoobReceive);
    }

    LiveBattleScreen.deadlines = [28, 10, 10, 10, 0, 1];
    _friendsHead = (widget.args["friendsHead"] as Opponent?) ?? _account;
    _oppositesHead = (widget.args["oppositesHead"] as Opponent?) ??
        Opponent.initialize({
          "id": 1,
          "level": 10,
          "xp": 1200,
          "name": "Tester",
          "tribe_name": "tribe"
        }, _account.id);

    _warriorsNotifier.add(_friendsHead.id,
        LiveWarrior(WarriorSide.friends, _friendsHead.id, _friendsHead));
    _warriorsNotifier.add(_oppositesHead.id,
        LiveWarrior(WarriorSide.opposites, _oppositesHead.id, _oppositesHead));
    if (!_friendsHead.itsMe) {
      _warriorsNotifier.add(_account.id,
          LiveWarrior(WarriorSide.friends, _friendsHead.id, _account));
    }

    _deckCards.value = _account.getReadyCards(isClone: true);
    for (var card in _deckCards.value) {
      card!.isDeployed = false;
    }
    _deckCards.value.sort((a, b) {
      int x = 1, y = 1;

      var aCoolDown = a!.getRemainingCooldown();
      var bCoolDown = b!.getRemainingCooldown();

      if (a.base.isHero && aCoolDown == 0) x += 2;
      if (b.base.isHero && bCoolDown == 0) y += 2;

      if (aCoolDown > 0) x -= 3;
      if (bCoolDown > 0) y -= 3;

      if (a.power > b.power) {
        x++;
      } else {
        y++;
      }
      return y - x;
    });
    _maxPower = _account.calculateMaxPower();
    _pageController = PageController(viewportFraction: 0.25);
    super.initState();
    _setSlotTime(0);
    WidgetsBinding.instance.addPostFrameCallback((d) {
      if (!isTutorial) {
        _timer = Timer.periodic(const Duration(milliseconds: 334),
            (t) => _setSlotTime((_seconds += 0.334).round()));
        _pageController.jumpToPage(0);
      }
    });
    if (_battleId == 0) {
      _warriorsNotifier.add(
          1,
          LiveWarrior(
              WarriorSide.opposites, _oppositesHead.id, _oppositesHead));
      // var cards = _account.getReadyCards(removeHeroes: true);
      // Timer.periodic(const Duration(seconds: 4), (timer) {
      // var index = timer.tick - 1;
      // if (index < 4) {
      //   _warriors[1]!.cards.setAtCard(index, cards[index]);
      //   _updatePowerBalance();
      // }
      // if (index == 5 && !isTutorial) {
      //   var noobMessage = NoobMessage.getProperMessage(
      //       _account,
      //       jsonDecode(
      //           '{"id":0,"players_info":{"${_friendsHead.id}":{"power":3741051,"cooldown":2697,"hero_power_benefit":0,"hero_wisdom_benefit":"5267","hero_blessing_multiplier":0.26666666666667,"won_battle_num":13,"lost_battle_num":34,"id":${_friendsHead.id},"name":"yasamanjoon","added_xp":244,"added_gold":3358,"league_bonus":766.8385059161094,"gold":9739107481,"xp":32531,"league_rank":61,"level":43,"rank":161056,"levelup_gold_added":0,"gift_card":null,"owner_team_id":254512,"q":4258,"hero_benefits_info":{"gold_benefit":707,"cooldown_benefit":5267}},"0":{"power":62416,"cooldown":1995,"hero_power_benefit":0,"hero_wisdom_benefit":0,"hero_blessing_multiplier":0,"won_battle_num":259,"lost_battle_num":99,"is_ignored":true,"id":0,"name":"a.h.alavii","added_xp":0,"added_gold":0,"gold":6752,"xp":242935,"level":90,"league_rank":13010,"rank":64400,"owner_team_id":0,"hero_benefits_info":[]},"1":{"power":62416,"cooldown":1995,"hero_power_benefit":0,"hero_wisdom_benefit":0,"hero_blessing_multiplier":0,"won_battle_num":259,"lost_battle_num":99,"is_ignored":true,"id":1,"name":"a.h.alavii","added_xp":0,"added_gold":0,"gold":6752,"xp":242935,"level":90,"league_rank":13010,"rank":64400,"owner_team_id":0,"hero_benefits_info":[]}},"result":{"winner_added_score":20,"loser_added_score":-20,"winner_tribe_rank":10240,"loser_tribe_rank":1635,"winner_tribe_name":"سالوادور🫀","loser_tribe_name":"بزرگان مشهد","winner_id":254512,"loser_id":0},"push_message_type":"battle_finished"}'));
      //   _onNoobReceive(noobMessage);
      //   timer.cancel();
      // }
      // });
    }
  }

  @override
  void onTutorialStart(data) {
    if (data["id"] == 903) {
      _pageController.jumpToPage(5);
    }
    super.onTutorialStart(data);
  }

  @override
  void onTutorialStep(data) async {
    if (data["id"] == 904) {
      //deploy card
      _warriors[_account.id]!
          .cards
          .setAtCard(0, _deckCards.value[5], toggleMode: false);
      // _warriors[1]!.cards.setAtCard(index, cards[index]);
      var slot = _slotState.value;
      _gotoNextSlot(0, slot);
      _updatePowerBalance();
    } else if (data["id"] == 906) {
      //second card and show time
    } else if (data["id"] == 908) {
      //timeout second card
      _warriors[_account.id]!
          .cards
          .setAtCard(_slotState.value.i, null, toggleMode: false);
      _gotoNextSlot(1, _slotState.value);
    } else if (data["id"] == 912) {
      //add tribemate
      _addWarrior(_account.id, 2, "یار کمکی");
    } else if (data["id"] == 913) {
      //add tribemate
      _warriors[2]!.cards.setAtCard(1, _deckCards.value[5], toggleMode: false);
    } else if (data["id"] == 915) {
      //go to hero page
      _pageController.jumpToPage(0);
    } else if (data["id"] == 917) {
      //deploy hero card
      _warriors[_account.id]!
          .cards
          .setAtCard(4, _deckCards.value[0], toggleMode: false);
      _updatePowerBalance();
    } else if (data["id"] == 918) {
      //close and go to opponent for status guid
      _close();
    }
    super.onTutorialStep(data);
  }

  GlobalKey heroKey = GlobalKey();

  @override
  Widget contentFactory() {
    var myCards = _warriors[_account.id]!.cards;
    var oppositesHeadCards = _warriors[_oppositesHead.id]!.cards;
    return Widgets.rect(
        color: const Color(0xffAA9A45),
        child: Stack(
          alignment: const Alignment(0, -0.1),
          children: [
            Align(
                alignment: const Alignment(-1.1, -0.28),
                child: ValueListenableBuilder<int>(
                  valueListenable: _powerBalance,
                  builder: (context, value, child) =>
                      PowerBalance(value, _maxPower),
                )),
            LiveSlot(0, -0.75, -0.30, 0.20, _slotState, oppositesHeadCards),
            LiveSlot(1, -0.26, -0.27, 0.07, _slotState, oppositesHeadCards),
            LiveSlot(2, 0.26, -0.27, -0.07, _slotState, oppositesHeadCards),
            LiveSlot(3, 0.75, -0.30, -0.20, _slotState, oppositesHeadCards),
            LiveSlot(0, -0.75, 0.10, -0.20, _slotState, myCards),
            LiveSlot(1, -0.26, 0.07, -0.07, _slotState, myCards),
            LiveSlot(2, 0.26, 0.07, 0.07, _slotState, myCards),
            LiveSlot(3, 0.75, 0.10, 0.20, _slotState, myCards),
            LiveHero(_battleId, -0.45, oppositesHeadCards, key: heroKey),
            LiveHero(_battleId, 0.35, myCards),
            LiveDeck(_pageController, _deckCards, _onDeckFocus, _onDeckSelect),
            LiveTribe(
                _oppositesHead.id, _battleId, _helpCost, _warriorsNotifier),
            LiveTribe(_friendsHead.id, _battleId, _helpCost, _warriorsNotifier,
                isTutorial: true),
            Positioned(
                width: 120.d,
                right: 40.d,
                child: SkinnedButton(label: "x", onPressed: _close))
          ],
        ));
  }

  void _onDeckFocus(int index, AccountCard focusedCard) {
    var slot = _slotState.value;
    var mySlots = _warriors[_account.id]!.cards;
    if (focusedCard.base.isHero) {
      if (slot.i < 5) {
        mySlots.setAtCard(slot.i, null);
      }
      mySlots.setAtCard(4, focusedCard);
      return;
    }
    if (slot.i == 5) return;
    mySlots.setAtCard(slot.i, focusedCard);
    if (mySlots.value[4] != null && !mySlots.value[4]!.isDeployed) {
      mySlots.setAtCard(4, null);
    }
    _updatePowerBalance();
  }

  Future<void> _onDeckSelect(int index, AccountCard selectedCard) async {
    if (_battleId == 0) {
      _deployCard(index, selectedCard);
      return;
    }
    if (!_isDeckActive) return;
    try {
      _isDeckActive = false;
      var round = _slotState.value.i + 1;
      if (selectedCard.base.isHero) {
        round = 5;
      } else if (round > 4) {
        return;
      }
      var params = {
        RpcParams.battle_id.name: _battleId,
        RpcParams.card.name: selectedCard.id,
        RpcParams.round.name: round,
      };
      var result = await rpc(RpcId.battleSetCard, params: params);
      selectedCard.lastUsedAt = result["last_used_at"];
      _deployCard(index, selectedCard);
    } finally {}
    _isDeckActive = true;
  }

  void _deployCard(int index, AccountCard selectedCard) {
    _account.cards[selectedCard.id]?.lastUsedAt = selectedCard.lastUsedAt;

    var slot = _slotState.value;
    if (slot.i == 5 && !selectedCard.base.isHero) return;
    var mySlots = _warriors[_friendsHead.id]!.cards;
    selectedCard.isDeployed = true;
    if (selectedCard.base.isHero) {
      _deckCards.removeWhere((card) => card!.base.isHero);
      mySlots.setAtCard(4, selectedCard, toggleMode: false);
    } else {
      _deckCards.remove(selectedCard);
      _gotoNextSlot(index, slot);
    }

    // Focus to the nearest card for the next slot
    index = index.max(_deckCards.value.length - 1);
    _onDeckFocus(index, _deckCards.value[index]!);
  }

  void _setSlot(int i, int j) {
    _slotState.value = IntVec2d(i, j);
  }

  void _setSlotTime(int tick) {
    if (_slotState.value.i == 5) return;
    var sum = 0.0;
    for (var i = 0; i < LiveBattleScreen.deadlines.length; i++) {
      sum += LiveBattleScreen.deadlines[i];
      if (tick < sum) {
        if (i > _slotState.value.i) {
          var mySlots = _warriors[_friendsHead.id]!.cards;
          mySlots.setAtCard(_slotState.value.i, null, toggleMode: false);
          var index = _pageController.page!.round();
          _gotoNextSlot(index, _slotState.value);
        }
        _setSlot(i, (sum - tick).round());
        return;
      }
    }
    _timer?.cancel();
  }

  void _gotoNextSlot(int index, IntVec2d slot) {
    if (slot.i >= 3) {
      _setSlot(5, slot.j);
      return;
    }
    var i = slot.i + 1;
    var sum = 0.0;
    for (var d = 0; d < i; d++) {
      sum += LiveBattleScreen.deadlines[d];
    }
    // Save remaining time to next slot
    sum -= _seconds - 1;
    LiveBattleScreen.deadlines[slot.i] -= sum;
    LiveBattleScreen.deadlines[i] += sum;

    _setSlot(i, slot.j);
    _setSlotTime(_seconds.round());
  }

  void _onNoobReceive(NoobMessage message) {
    if (message.id != _battleId) {
      return;
    }
    if (message.type == Noobs.battleJoin) {
      var msg = message as NoobJoinBattleMessage;
      _addWarrior(msg.teamOwnerId, msg.warriorId, msg.warriorName);
    } else if (message.type == Noobs.deployCard) {
      _handleCardMessage(message as NoobCardMessage);
    } else if (message.type == Noobs.heroAbility) {
      _handleAbilityMessage(message as NoobAbilityMessage);
    } else if (message.type == Noobs.battleEnd) {
      _handleEndingMessage(message as NoobEndBattleMessage);
    }
  }

  void _addWarrior(int teamOwnerId, int id, String name) {
    if (_warriors.containsKey(id)) return;
    _warriorsNotifier.add(
        id,
        LiveWarrior(_warriors[teamOwnerId]!.side, teamOwnerId,
            Opponent.create(id, name, _account.id)));
  }

  void _handleCardMessage(NoobCardMessage message) {
    var cardOwnerId = message.card!.ownerId;
    _addWarrior(message.teamOwnerId, cardOwnerId, message.ownerName);
    var index = message.round.max(5) - 1;
    _warriors[cardOwnerId]?.cards.setAtCard(index, message.card);
    _updatePowerBalance();
  }

  void _updatePowerBalance() {
    var powerBalance = 0; // _account.calculatePower(_mySlots.value);
    for (var warrior in _warriors.values) {
      var coef = warrior.teamOwnerId == _friendsHead.id ? 1 : -1;
      for (var card in warrior.cards.value) {
        if (card != null) powerBalance += card.power * coef;
      }
    }

    var max = (powerBalance.abs() * (1 + Random().nextDouble() * 0.2)).round();
    if (_maxPower < max) _maxPower = max;
    _powerBalance.value = powerBalance;
  }

  void _handleAbilityMessage(NoobAbilityMessage message) {
    for (var entry in message.cards.entries) {
      var index = _warriors[message.ownerId]!
          .cards
          .value
          .indexWhere((c) => c != null && "${c.id}" == entry.key);
      if (index > -1) {
        var card = _warriors[message.ownerId]!.cards.value[index]!;
        if (message.ability == Abilities.power) {
          card.power += entry.value;
          var state = heroKey.currentState! as LiveHeroState;
          var controller = state.stateMachineController;
          if (controller != null) {
            var powerTrigger =
                controller.findInput<bool>("benefitPower") as SMITrigger;

            controller.artboard!.component<TextValueRun>("PowerText")?.text =
                entry.value.toString();
            controller.artboard!
                .component<TextValueRun>("PowerText_stroke")
                ?.text = entry.value.toString();
            controller.artboard!
                .component<TextValueRun>("PowerText_shadow")
                ?.text = entry.value.toString();
            powerTrigger.value = !powerTrigger.value;
            powerTrigger.fire();
          }
        } else {
          card.lastUsedAt = entry.value;
          _account.cards[card.id]?.lastUsedAt = card.lastUsedAt;
        }
        _warriors[message.ownerId]!
            .cards
            .setAtCard(index, card, toggleMode: false);
        _updatePowerBalance();
      }
    }
  }

  void _handleEndingMessage(NoobEndBattleMessage message) {
    for (var info in message.opponentsInfo) {
      var warrior = _warriors[info["id"]]!;
      warrior.addResult(info);
      warrior.won = warrior.teamOwnerId == message.winnerId;
      if (warrior.teamOwnerId == _friendsHead.id) {
        if (warrior.base.id == _friendsHead.id) {
          warrior.score =
              warrior.won ? message.winnerScore : message.loserScore;
        }
        warrior.tribeName =
            warrior.won ? message.winnerTribe : message.loserTribe;
      } else {
        if (warrior.base.id == _oppositesHead.id) {
          warrior.score =
              warrior.won ? message.winnerScore : message.loserScore;
        }
        warrior.tribeName =
            warrior.won ? message.winnerTribe : message.loserTribe;
      }
    }

    // Reset reminder notifications ....
    serviceLocator<Notifications>()
        .schedule(accountProvider.account.getSchedules());

    serviceLocator<RouteService>().to(Routes.liveBattleOut, args: {
      "friendsId": _friendsHead.id,
      "oppositesId": _oppositesHead.id,
      "warriors": _warriors.values.toList()
    });
  }

  void _close() {
    serviceLocator<NoobSocket>().onReceive.remove(_onNoobReceive);
    _timer?.cancel();
    _pageController.dispose();
    Navigator.pop(context);
  }
}

class Warriors extends ValueNotifier<Map<int, LiveWarrior>> {
  Warriors() : super({});

  void add(int id, LiveWarrior warrior) {
    value[id] = warrior;
    notifyListeners();
  }
}
