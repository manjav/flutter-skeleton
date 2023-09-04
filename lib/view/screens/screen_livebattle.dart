import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/infra.dart';
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
  final Map<int, LiveCardsData> _slots = {};
  final SelectedCards _deckCards = SelectedCards([]);
  final ValueNotifier<int> _powerBalance = ValueNotifier(0);
  final ValueNotifier<IntVec2d> _slotState = ValueNotifier(IntVec2d(0, 0));
  late Timer _timer;
  double _seconds = 0;
  int _maxPower = 0;
  bool _isDeckActive = true;
  int _battleId = 0, _alliseId = 0, _axisId = 0;

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
    var opponent = widget.args["opponent"];
    _alliseId = _account.get<int>(AccountField.id);
    _axisId = opponent == null ? 0 : widget.args["opponent"].id;
    if (_slots.isEmpty) {
      _slots[_alliseId] = LiveCardsData(_alliseId, _alliseId);
      _slots[_axisId] = LiveCardsData(_axisId, _axisId);
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
            LiveSlot(0, -0.75, -0.20, 0.20, _slotState, _slots[_axisId]!),
            LiveSlot(1, -0.26, -0.17, 0.07, _slotState, _slots[_axisId]!),
            LiveSlot(2, 0.26, -0.17, -0.07, _slotState, _slots[_axisId]!),
            LiveSlot(3, 0.75, -0.20, -0.20, _slotState, _slots[_axisId]!),
            LiveSlot(0, -0.75, 0.20, -0.20, _slotState, _slots[_alliseId]!),
            LiveSlot(1, -0.26, 0.17, -0.07, _slotState, _slots[_alliseId]!),
            LiveSlot(2, 0.26, 0.17, 0.07, _slotState, _slots[_alliseId]!),
            LiveSlot(3, 0.75, 0.20, 0.20, _slotState, _slots[_alliseId]!),
            LiveHero(_battleId, -0.35, _slots[_axisId]!),
            LiveHero(_battleId, 0.45, _slots[_alliseId]!),
            LiveDeck(_pageController, _deckCards, _onDeckFocus, _onDeckSelect),
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
    var mySlots = _slots[mId]!;
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
    var mySlots = _slots[_account.get<int>(AccountField.id)]!;
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
    // const helpTimeout = 37;
    var sum = 0.0;
    for (var i = 0; i < LiveBattleScreen.deadlines.length; i++) {
      sum += LiveBattleScreen.deadlines[i];
      if (tick < sum) {
        if (i > _slotState.value.i) {
          var mySlots = _slots[_account.get<int>(AccountField.id)]!;
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
    if (cardOwnerId == _account.get(AccountField.id)) {
      var index = _deckCards.value.indexWhere((c) => c!.id == message.card!.id);
      _deckCards.value[index]!.lastUsedAt = message.card!.lastUsedAt;
      _deployCard(index, _deckCards.value[index]!);
    } else {
      if (!_slots.containsKey(cardOwnerId)) {
        _slots[cardOwnerId] = LiveCardsData(cardOwnerId, message.teamOwnerId);
      }
      _slots[cardOwnerId]!.setAtCard(message.round - 1, message.card);
    }
    _updatePowerBalance();
  }

  void _updatePowerBalance() {
    var powerBalance = 0; // _account.calculatePower(_mySlots.value);
    for (var slot in _slots.values) {
      var coef = slot.teamOwnerId == _alliseId ? 1 : -1;
      for (var card in slot.value) {
        if (card != null) powerBalance += card.power * coef;
      }
    }

    var max = (powerBalance.abs() * (1 + Random().nextDouble() * 0.2)).round();
    if (_maxPower < max) _maxPower = max;
    _powerBalance.value = powerBalance;
  }

  void _handleAbilityMessage(NoobAbilityMessage message) {
    for (var entry in message.cards.entries) {
      var index = _slots[message.ownerId]!
          .value
          .indexWhere((c) => c != null && "${c.id}" == entry.key);
      if (index > -1) {
        var card = _slots[message.ownerId]!.value[index]!;
        if (message.ability == Abilities.power) {
          card.power = entry.value;
        } else {
          card.lastUsedAt = entry.value;
          _account.getCards()[card.id]!.lastUsedAt = card.lastUsedAt;
        }
        _slots[message.ownerId]!.setAtCard(index, card, toggleMode: false);
        _updatePowerBalance();
      }
    }
  }

  void _handleFineMessage(NoobFineMessage message) {
    message.addBattleData(_alliseId, _axisId, _slots);
    Navigator.pushNamed(context, Routes.livebattleOut.routeName,
        arguments: {"result": message});
  }

  void _close() {
    BlocProvider.of<ServicesBloc>(context).get<NoobSocket>().onReceive = null;
    _timer.cancel();
    _pageController.dispose();
    Navigator.pop(context);
  }
}
