import 'dart:async';

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

class LiveCardsData extends SelectedCards {
  final int ownerId, teamOwnerId;
  LiveCardsData(this.ownerId, this.teamOwnerId)
      : super([null, null, null, null, null]);
}

class LiveBattleScreen extends AbstractScreen {
  static List<double> deadlines = [27, 10, 0, 10, 10, 1];
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
  int _battleId = 0;
  int _maxPower = 0;

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    // ,{"battle_id":42224570,"help_cost":5464}
    _battleId = widget.args["battle_id"] ?? 0;
    BlocProvider.of<ServicesBloc>(context).get<NoobSocket>().onReceive =
        _onNoobReceive;

    LiveBattleScreen.deadlines = [27, 10, 0, 10, 10, 1];
    _account = BlocProvider.of<AccountBloc>(context).account!;
    var mId = _account.get<int>(AccountField.id);
    var oId = widget.args["opponent"]["id"];
    _slots[mId] = LiveCardsData(mId, mId);
    _slots[oId] = LiveCardsData(oId, oId);

    _deckCards.value = _account.getReadyCards();
    for (var card in _deckCards.value) {
      card!.isDeployed = false;
    }
    _maxPower = _account.get<int>(AccountField.def_power);
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
    var mId = _account.get<int>(AccountField.id);
    var oId = widget.args["opponent"]["id"];
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
            LiveSlot(0, -0.75, -0.20, 0.20, _slotState, _slots[oId]!),
            LiveSlot(1, -0.26, -0.17, 0.07, _slotState, _slots[oId]!),
            LiveSlot(2, 0.26, -0.17, -0.07, _slotState, _slots[oId]!),
            LiveSlot(3, 0.75, -0.20, -0.20, _slotState, _slots[oId]!),
            LiveSlot(0, -0.75, 0.20, -0.20, _slotState, _slots[mId]!),
            LiveSlot(1, -0.26, 0.17, -0.07, _slotState, _slots[mId]!),
            LiveSlot(2, 0.26, 0.17, 0.07, _slotState, _slots[mId]!),
            LiveSlot(3, 0.75, 0.20, 0.20, _slotState, _slots[mId]!),
            LiveHero(_battleId, -0.35, _slots[oId]!),
            LiveHero(_battleId, 0.45, _slots[mId]!),
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

    var powerBalance = 0; // _account.calculatePower(_mySlots.value);
    for (var slot in _slots.values) {
      var coef = slot.teamOwnerId == mId ? 1 : -1;
      for (var card in slot.value) {
        if (card != null) powerBalance += card.power * coef;
      }
    }
    _powerBalance.value = powerBalance;
  }

  void _onDeckSelect(int index, AccountCard selectedCard) {
    try {
      var params = {
        RpcParams.battle_id.name: _battleId,
        RpcParams.card.name: selectedCard.id,
        RpcParams.round.name:
            selectedCard.base.isHero ? 5 : _slotState.value.i + 1,
      };
      BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.battleSetCard, params: params);
    } finally {}
  }

  _deployCard(int index, AccountCard selectedCard) {
    var slot = _slotState.value;
    if (slot.i == 5) return;
    var mySlots = _slots[_account.get<int>(AccountField.id)]!;
    selectedCard.isDeployed = true;
    if (selectedCard.base.isHero) {
      _deckCards.removeWhere((card) => card!.base.isHero);
      _mySlots.setAtCard(2, selectedCard, toggleMode: false);
    } else {
      _deckCards.remove(selectedCard);

      // Save remaining time to next slot
      var i = slot.i + (slot.i == 1 ? 2 : 1);
      var sum = 0.0;
      for (var d = 0; d < i; d++) {
        sum += LiveBattleScreen.deadlines[d];
      }
      sum -= _seconds - 1;
      LiveBattleScreen.deadlines[slot.i] -= sum;
      LiveBattleScreen.deadlines[i] += sum;

      _setSlot(i, slot.j);
      _setSlotTime(_seconds.round());
    }

    // Focus to the nearest card for the next slot
    index = index.max(_deckCards.value.length - 1);
    _onDeckFocus(index, _deckCards.value[index]!);
  }

  void _setSlot(int i, int j) {
    _slotState.value = IntVec2d(i, j);
  }

  void _setSlotTime(int tick) {
    // const helpTimeout = 37;
    var sum = 0.0;
    for (var i = 0; i < LiveBattleScreen.deadlines.length; i++) {
      sum += LiveBattleScreen.deadlines[i];
      if (tick < sum) {
        if (i > _slotState.value.i) {
          var index = _pageController.page!.round();
          _onDeckSelect(index, _deckCards.value[index]!);
        }
        _setSlot(i, (sum - tick).round());
        return;
      }
    }
    _timer.cancel();
  }

  void _onNoobReceive(NoobMessage message) {
    if (message.type != NoobMessages.battleUpdate) {
      return;
    }
    var battleMessage = message as NoobBattleMessage;
    if (battleMessage.id != _battleId) {
      return;
    }
    var slotIndex = battleMessage.round == 5 ? 2 : battleMessage.round - 1;
    if (battleMessage.card!.ownerId == _account.get(AccountField.id)) {
      var index =
          _deckCards.value.indexWhere((c) => c!.id == battleMessage.card!.id);
      _deckCards.value[index]!.lastUsedAt = battleMessage.card!.lastUsedAt;
      _deployCard(index, _deckCards.value[index]!);
    } else {
      _enemySlots.setAtCard(slotIndex, battleMessage.card);
    }
  }

  void _close() {
    BlocProvider.of<ServicesBloc>(context).get<NoobSocket>().onReceive = null;
    _timer.cancel();
    _pageController.dispose();
    Navigator.pop(context);
  }
}
