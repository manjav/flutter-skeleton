import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../view/widgets/card_holder.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/power_balance.dart';
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
  final SelectedCards _myDeloyedCards = SelectedCards([null, null, null, null]);
  final SelectedCards _enemyDeployedCards =
      SelectedCards([null, null, null, null]);
  final ValueNotifier<int> _powerBalance = ValueNotifier(0);
  int _maxPower = 0;
  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _cards = _account.getReadyCards();
    _maxPower = _account.get<int>(AccountField.def_power);
    super.initState();
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
        ));
  }

  _deckItemBuilder(int index, double alignX, double alignY, double rotation) {
    return Align(
        alignment: Alignment(alignX + 0.05, alignY),
        child: Transform.rotate(
            angle: rotation + Random().nextDouble() * 0.16 - 0.08,
            child: Asset.load<Image>(
                "deck_live_${index > 1 ? "missed" : "empty"}",
                width: 200.d)));
  }
  
  void _onCardFocusChanged(int index, AccountCard focusedCard) {
    print(index);
  }
}
