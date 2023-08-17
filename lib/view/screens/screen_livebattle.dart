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
        ));
  }

  
}
