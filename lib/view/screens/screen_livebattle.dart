import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/infra.dart';
import '../../data/core/ranking.dart';
import '../../services/deviceinfo.dart';
import '../../view/widgets/card_holder.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/live_battle/live_deck.dart';
import '../widgets/live_battle/live_hero.dart';
import '../widgets/live_battle/live_slot.dart';
import '../widgets/live_battle/power_balance.dart';
import 'iscreen.dart';

class LiveBattleScreen extends AbstractScreen {
  LiveBattleScreen({super.key}) : super(Routes.livebattle);

  @override
  createState() => _LiveBattleScreenState();
}

class _LiveBattleScreenState extends AbstractScreenState<AbstractScreen> {
  late Account _account;
  late PageController _pageController;
  final SelectedCards _mySlots = SelectedCards([null, null, null, null, null]);
  final SelectedCards _enemySlots =
      SelectedCards([null, null, null, null, null]);
  final ValueNotifier<int> _powerBalance = ValueNotifier(0);
  int _maxPower = 0;
  final SelectedCards _deckCards = SelectedCards([]);
  bool _isHeroDeployed = false;
  final ValueNotifier<IntVec2d> _currentHolder = ValueNotifier(IntVec2d(0, 0));

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _deckCards.value = _account.getReadyCards();
    _maxPower = _account.get<int>(AccountField.def_power);
    _pageController = PageController(viewportFraction: 0.25);
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((d) => _pageController.jumpToPage(4));
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
            LiveSlot(0, -0.75, -0.20, 0.20, _slotState, _enemySlots),
            LiveSlot(1, -0.26, -0.17, 0.07, _slotState, _enemySlots),
            LiveSlot(3, 0.26, -0.17, -0.07, _slotState, _enemySlots),
            LiveSlot(4, 0.75, -0.20, -0.20, _slotState, _enemySlots),
            LiveSlot(0, -0.75, 0.20, -0.20, _slotState, _mySlots),
            LiveSlot(1, -0.26, 0.17, -0.07, _slotState, _mySlots),
            LiveSlot(3, 0.26, 0.17, 0.07, _slotState, _mySlots),
            LiveSlot(4, 0.75, 0.20, 0.20, _slotState, _mySlots),
            LiveHero(_account, OpponentMode.axis, _enemySlots),
            LiveHero(_account, OpponentMode.allise, _mySlots),
            LiveDeck(_pageController, _deckCards, _onDeckFocus, _onDeckSelect),
          ],
        ));
  }
  
  void _onDeckFocus(int index, AccountCard focusedCard) {
    var slot = _slotState.value;
    if (slot.i == 5) return;
    if (focusedCard.base.isHero) {
      _mySlots.setAtCard(slot.i, null);
      _mySlots.setAtCard(2, focusedCard);
    } else {
      _mySlots.setAtCard(slot.i, focusedCard);
      if (!_isHeroDeployed) {
        _mySlots.setAtCard(2, null);
    }
    }
    var powerBalance = _account.calculatePower(_mySlots.value);
    _powerBalance.value = powerBalance;
  }

  void _onDeckSelect(int index, AccountCard selectedCard) {
    var slot = _slotState.value;
    if (slot.i == 5) return;
    if (selectedCard.base.isHero) {
      _isHeroDeployed = true;
      _deckCards.removeWhere((card) => card!.base.isHero);
    } else {
      _deckCards.remove(selectedCard);
    }
    _onDeckFocus(index, _deckCards.value[index]!);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
