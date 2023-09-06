import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/infra.dart';
import '../../data/core/ranking.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/connection/noob_socket.dart';
import '../../services/deviceinfo.dart';
import '../../utils/utils.dart';
import '../../view/widgets/card_holder.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/live_battle/live_deck.dart';
import '../widgets/live_battle/live_hero.dart';
import '../widgets/live_battle/live_slot.dart';
import '../widgets/live_battle/live_tribe.dart';
import '../widgets/live_battle/power_balance.dart';
import 'iscreen.dart';

class LiveBattleScreen extends AbstractScreen {
  static List<double> deadlines = [];
  LiveBattleScreen({required super.args, super.key})
      : super(Routes.livebattle, closable: false);

  @override
  createState() => _LiveBattleScreenState();
}

class _LiveBattleScreenState extends AbstractScreenState<LiveBattleScreen> {
  late Account _account;
  late PageController _pageController;
  final Map<int, LiveOpponent> _opponents = {};
  final SelectedCards _deckCards = SelectedCards([]);
  final ValueNotifier<int> _powerBalance = ValueNotifier(0);
  final ValueNotifier<IntVec2d> _slotState = ValueNotifier(IntVec2d(0, 0));
  late Timer _timer;
  double _seconds = 0;
  int _maxPower = 0;
  bool _isDeckActive = true;
  int _battleId = 0;
  late Opponent _allies, _axis;

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _battleId = widget.args["battle_id"] ?? 0;
    BlocProvider.of<ServicesBloc>(context).get<NoobSocket>().onReceive =
        _onNoobReceive;

    LiveBattleScreen.deadlines = [27, 10, 10, 10, 0, 1];
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _allies = _account.toOpponent();
    _axis = (widget.args["opponent"] as Opponent?) ??
        Opponent.init(
            {"level": 10, "xp": 1200, "name": "Test", "tribe_name": "tribe"},
            _allies.id);

    if (_opponents.isEmpty) {
      _opponents[_allies.id] =
          LiveOpponent(OpponentSide.allies, _allies.id, _allies.id, _allies);
      _opponents[_axis.id] =
          LiveOpponent(OpponentSide.axis, _axis.id, _axis.id, _axis);
    }

    _deckCards.value = _account.getReadyCards(isClone: true);
    for (var card in _deckCards.value) {
      card!.isDeployed = false;
    }
    _maxPower = _account.calculateMaxPower();
    _pageController = PageController(viewportFraction: 0.25);
    super.initState();
    _setSlotTime(0);
    WidgetsBinding.instance.addPostFrameCallback((d) {
      _timer = Timer.periodic(const Duration(milliseconds: 334),
          (t) => _setSlotTime((_seconds += 0.334).round()));
      _pageController.jumpToPage(4);
    });
  }

  @override
  Widget contentFactory() {
    var alliseCards = _opponents[_allies.id]!.cards;
    var axisCards = _opponents[_axis.id]!.cards;
    return Widgets.rect(
        color: const Color(0xffAA9A45),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
                left: -48.d,
                child: ValueListenableBuilder<int>(
                    valueListenable: _powerBalance,
                    builder: (context, value, child) =>
                        Powerbalance(value, _maxPower))),
            LiveSlot(0, -0.75, -0.20, 0.20, _slotState, axisCards),
            LiveSlot(1, -0.26, -0.17, 0.07, _slotState, axisCards),
            LiveSlot(2, 0.26, -0.17, -0.07, _slotState, axisCards),
            LiveSlot(3, 0.75, -0.20, -0.20, _slotState, axisCards),
            LiveSlot(0, -0.75, 0.20, -0.20, _slotState, alliseCards),
            LiveSlot(1, -0.26, 0.17, -0.07, _slotState, alliseCards),
            LiveSlot(2, 0.26, 0.17, 0.07, _slotState, alliseCards),
            LiveSlot(3, 0.75, 0.20, 0.20, _slotState, alliseCards),
            LiveHero(_battleId, -0.35, axisCards),
            LiveHero(_battleId, 0.45, alliseCards),
            LiveDeck(_pageController, _deckCards, _onDeckFocus, _onDeckSelect),
            LiveTribe(_axis.id, _opponents, _helpCost),
            LiveTribe(_allies.id, _opponents, _helpCost),
            Positioned(
                width: 440.d,
                bottom: 4.d,
                height: 60,
                child: Widgets.skinnedButton(label: ">", onPressed: _close))
          ],
        ));
  }

  void _onDeckFocus(int index, AccountCard focusedCard) {
    var slot = _slotState.value;
    if (slot.i == 5) return;
    var mId = _account.get<int>(AccountField.id);
    var mySlots = _opponents[mId]!.cards;
    if (focusedCard.base.isHero) {
      mySlots.setAtCard(slot.i, null);
      mySlots.setAtCard(4, focusedCard);
    } else {
      mySlots.setAtCard(slot.i, focusedCard);
      if (mySlots.value[4] != null && !mySlots.value[4]!.isDeployed) {
        mySlots.setAtCard(4, null);
      }
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
      var params = {
        RpcParams.battle_id.name: _battleId,
        RpcParams.card.name: selectedCard.id,
        RpcParams.round.name: _slotState.value.i + 1,
      };
      await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.battleSetCard, params: params);
    } finally {}
    _isDeckActive = true;
  }

  _deployCard(int index, AccountCard selectedCard) {
    var slot = _slotState.value;
    if (slot.i == 5) return;
    var mySlots = _opponents[_allies.id]!.cards;
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
          var mySlots = _opponents[_allies.id]!.cards;
          mySlots.setAtCard(_slotState.value.i, null, toggleMode: false);
          var index = _pageController.page!.round();
          _gotoNextSlot(index, _slotState.value);
        }
        _setSlot(i, (sum - tick).round());
        return;
      }
    }
    _timer.cancel();
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
    return switch (message.type) {
      NoobMessages.deployCard => _handleCardMessage(message as NoobCardMessage),
      NoobMessages.heroAbility =>
        _handleAbilityMessage(message as NoobAbilityMessage),
      NoobMessages.battleFinished =>
        _handleFineMessage(message as NoobFineMessage),
      _ => print("")
    };
  }

  void _handleCardMessage(NoobCardMessage message) {
    var cardOwnerId = message.card!.ownerId;
    var fraction = message.teamOwnerId == _allies.id
        ? OpponentSide.allies
        : OpponentSide.axis;
    if (cardOwnerId == _account.get(AccountField.id)) {
      var index = _deckCards.value.indexWhere((c) => c!.id == message.card!.id);
      _deckCards.value[index]!.lastUsedAt = message.card!.lastUsedAt;
      _deployCard(index, _deckCards.value[index]!);
    } else {
      if (!_opponents.containsKey(cardOwnerId)) {
        _opponents[cardOwnerId] = LiveOpponent(
            fraction,
            cardOwnerId,
            message.teamOwnerId,
            Opponent.init({"name": message.ownerName}, _allies.id));
      }
      _opponents[cardOwnerId]!.cards.setAtCard(message.round - 1, message.card);
    }
    _updatePowerBalance();
  }

  void _updatePowerBalance() {
    var powerBalance = 0; // _account.calculatePower(_mySlots.value);
    for (var opponent in _opponents.values) {
      var coef = opponent.teamOwnerId == _allies.id ? 1 : -1;
      for (var card in opponent.cards.value) {
        if (card != null) powerBalance += card.power * coef;
      }
    }

    var max = (powerBalance.abs() * (1 + Random().nextDouble() * 0.2)).round();
    if (_maxPower < max) _maxPower = max;
    _powerBalance.value = powerBalance;
  }

  void _handleAbilityMessage(NoobAbilityMessage message) {
    for (var entry in message.cards.entries) {
      var index = _opponents[message.ownerId]!
          .cards
          .value
          .indexWhere((c) => c != null && "${c.id}" == entry.key);
      if (index > -1) {
        var card = _opponents[message.ownerId]!.cards.value[index]!;
        if (message.ability == Abilities.power) {
          card.power = entry.value;
        } else {
          card.lastUsedAt = entry.value;
          _account.getCards()[card.id]!.lastUsedAt = card.lastUsedAt;
        }
        _opponents[message.ownerId]!
            .cards
            .setAtCard(index, card, toggleMode: false);
        _updatePowerBalance();
      }
    }
  }

  void _handleFineMessage(NoobFineMessage message) {
    for (var info in message.opponentsInfo) {
      var oppo = _opponents[info["id"]]!;
      oppo.addResult(info);
      oppo.won = oppo.id == message.winnerId;
      if (oppo.teamOwnerId == _allies.id) {
        if (oppo.id == _allies.id) {
          oppo.score = oppo.won ? message.winnerScore : message.loserScore;
        }
        oppo.tribeName = oppo.won ? message.winnerTribe : message.loserTribe;
      } else {
        if (oppo.id == _axis.id) {
          oppo.score = oppo.won ? message.winnerScore : message.loserScore;
        }
        oppo.tribeName = oppo.won ? message.winnerTribe : message.loserTribe;
      }
    }

    Navigator.pushNamed(context, Routes.livebattleOut.routeName, arguments: {
      "alliseId": _allies.id,
      "axisId": _axis.id,
      "opponents": _opponents.values.toList()
    });
  }

  void _close() {
    BlocProvider.of<ServicesBloc>(context).get<NoobSocket>().onReceive = null;
    _timer.cancel();
    _pageController.dispose();
    Navigator.pop(context);
  }
}
