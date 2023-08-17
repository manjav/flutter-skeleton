import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../view/widgets/card_holder.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/live_battle/live_deck.dart';
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
  final SelectedCards _myDeloyedCards = SelectedCards([null, null, null, null]);
  final SelectedCards _enemyDeployedCards =
      SelectedCards([null, null, null, null]);
  final ValueNotifier<int> _powerBalance = ValueNotifier(0);
  int _maxPower = 0;
  List<AccountCard> _cards = [];

  int get _readySlotIndex => 0;

  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _cards = _account.getReadyCards();
    _maxPower = _account.get<int>(AccountField.def_power);
    _pageController = PageController(viewportFraction: 0.3, keepPage: true);
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
            DeployHolder(0, -0.85, -0.25, 0.2, _enemyDeployedCards),
            DeployHolder(1, -0.3, -0.21, 0.1, _enemyDeployedCards),
            DeployHolder(2, 0.3, -0.21, -0.1, _enemyDeployedCards),
            DeployHolder(3, 0.85, -0.25, -0.2, _enemyDeployedCards),
            DeployHolder(0, -0.85, 0.25, -0.2, _myDeloyedCards),
            DeployHolder(1, -0.3, 0.21, -0.1, _myDeloyedCards),
            DeployHolder(2, 0.3, 0.21, 0.1, _myDeloyedCards),
            DeployHolder(3, 0.85, 0.25, 0.2, _myDeloyedCards),
            LiveDeck(_pageController, _cards, _onCardFocusChanged),
        ));
  }
  
  void _onCardFocusChanged(int index, AccountCard focusedCard) {
    if (focusedCard.base.isHero) {
      _myDeloyedCards.setAtCard(_readySlotIndex, null);
    } else {
      _myDeloyedCards.setAtCard(_readySlotIndex, focusedCard);
    }
    var powerBalance = 0;
    for (var card in _myDeloyedCards.value) {
      powerBalance += card != null ? card.power : 0;
    }
    _powerBalance.value = powerBalance;
  }
}
