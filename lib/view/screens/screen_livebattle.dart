import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/ranking.dart';
import '../../services/deviceinfo.dart';
import '../../view/widgets/card_holder.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/live_battle/live_deck.dart';
import '../widgets/live_battle/live_hero.dart';
import '../widgets/live_battle/livebattle_deploy_holder.dart';
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
  final SelectedCards _myDeloyedCards =
      SelectedCards([null, null, null, null, null]);
  final SelectedCards _enemyDeployedCards =
      SelectedCards([null, null, null, null, null]);
  final ValueNotifier<int> _powerBalance = ValueNotifier(0);
  int _maxPower = 0;
  final SelectedCards _deckCards = SelectedCards([]);
  bool _isHeroDeployed = false;
  int _readySlotIndex = 0;

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            DeployHolder(0, -0.75, -0.20, 0.2, _enemyDeployedCards),
            DeployHolder(1, -0.26, -0.17, 0.1, _enemyDeployedCards),
            DeployHolder(3, 0.26, -0.17, -0.1, _enemyDeployedCards),
            DeployHolder(4, 0.75, -0.20, -0.2, _enemyDeployedCards),
            DeployHolder(0, -0.75, 0.20, -0.2, _myDeloyedCards),
            DeployHolder(1, -0.26, 0.17, -0.1, _myDeloyedCards),
            DeployHolder(3, 0.26, 0.17, 0.1, _myDeloyedCards),
            DeployHolder(4, 0.75, 0.20, 0.2, _myDeloyedCards),
            DeployHero(_account, OpponentMode.axis, _enemyDeployedCards),
            DeployHero(_account, OpponentMode.allise, _myDeloyedCards),
            LiveDeck(_pageController, _deckCards, _onDeckFocus, _onDeckSelect),
        ));
  }
  
  void _onDeckFocus(int index, AccountCard focusedCard) {
    if (_myDeloyedCards.value[4] != null) return;
    if (focusedCard.base.isHero) {
      _myDeloyedCards.setAtCard(_readySlotIndex, null);
      _myDeloyedCards.setAtCard(2, focusedCard);
    } else {
      _myDeloyedCards.setAtCard(_readySlotIndex, focusedCard);
      if (!_isHeroDeployed) {
        _myDeloyedCards.setAtCard(2, null);
    }
    var powerBalance = 0;
    for (var card in _myDeloyedCards.value) {
      powerBalance += card != null ? card.power : 0;
    }
    _powerBalance.value = powerBalance;
  }

  void _onDeckSelect(int index, AccountCard focusedCard) {
  }
}
