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
  final SelectedCards _myCards = SelectedCards([null, null, null, null, null]);
  final SelectedCards _enemyCards =
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
            DeployHolder(0, -0.75, -0.20, 0.2, _currentHolder, _enemyCards),
            DeployHolder(1, -0.26, -0.17, 0.1, _currentHolder, _enemyCards),
            DeployHolder(3, 0.26, -0.17, -0.1, _currentHolder, _enemyCards),
            DeployHolder(4, 0.75, -0.20, -0.2, _currentHolder, _enemyCards),
            DeployHolder(0, -0.75, 0.20, -0.2, _currentHolder, _myCards),
            DeployHolder(1, -0.26, 0.17, -0.1, _currentHolder, _myCards),
            DeployHolder(3, 0.26, 0.17, 0.1, _currentHolder, _myCards),
            DeployHolder(4, 0.75, 0.20, 0.2, _currentHolder, _myCards),
            DeployHero(_account, OpponentMode.axis, _enemyCards),
            DeployHero(_account, OpponentMode.allise, _myCards),
            LiveDeck(_pageController, _deckCards, _onDeckFocus, _onDeckSelect),
          ],
        ));
  }
  
  void _onDeckFocus(int index, AccountCard focusedCard) {
    var holder = _currentHolder.value;
    if (holder.i == 5) return;
    if (focusedCard.base.isHero) {
      _myCards.setAtCard(holder.i, null);
      _myCards.setAtCard(2, focusedCard);
    } else {
      _myCards.setAtCard(holder.i, focusedCard);
      if (!_isHeroDeployed) {
        _myCards.setAtCard(2, null);
    }
    }
    var powerBalance = _account.calculatePower(_myCards.value);
    _powerBalance.value = powerBalance;
  }

  void _onDeckSelect(int index, AccountCard focusedCard) {
    var holder = _currentHolder.value;
    if (holder.i == 5) return;
    if (focusedCard.base.isHero) {
      _isHeroDeployed = true;
      _deckCards.removeWhere((card) => card!.base.isHero);
    } else {
      _deckCards.remove(focusedCard);
      _currentHolder.value =
          IntVec2d(holder.i + (holder.i == 1 ? 2 : 1), holder.j);
    }
    _onDeckFocus(index, _deckCards.value[index]!);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
