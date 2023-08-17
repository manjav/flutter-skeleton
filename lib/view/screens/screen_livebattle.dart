import 'package:flutter/material.dart';

import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/power_balance.dart';
import 'iscreen.dart';

class LiveBattleScreen extends AbstractScreen {
  LiveBattleScreen({super.key}) : super(Routes.livebattle);

  @override
  createState() => _LiveBattleScreenState();
}

class _LiveBattleScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  Widget contentFactory() {
    return Widgets.rect(
        color: const Color(0xffAA9A45),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(left: 0, child: Powerbalance()),
            _deckItemBuilder(0, -0.85, -0.25, 0.2),
            _deckItemBuilder(1, -0.3, -0.21, 0.1),
            _deckItemBuilder(2, 0.3, -0.21, -0.1),
            _deckItemBuilder(3, 0.85, -0.25, -0.2),
            _deckItemBuilder(0, -0.85, 0.25, -0.2),
            _deckItemBuilder(1, -0.3, 0.21, -0.1),
            _deckItemBuilder(2, 0.3, 0.21, 0.1),
            _deckItemBuilder(3, 0.85, 0.25, 0.2),
            LiveDeck(_pageController, _readyCards, _onCardFocusChanged),
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
