import 'package:flutter/material.dart';

import '../../data/core/fruit.dart';
import '../../services/deviceinfo.dart';
import '../../view/items/card_item.dart';
import '../../view/mixins/reward_mixin.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'iscreen.dart';

class OpenPackScreen extends AbstractScreen {
  OpenPackScreen({required super.args, super.key}) : super(Routes.openPack);

  @override
  createState() => _OpenPackScreenState();
}

class _OpenPackScreenState extends AbstractScreenState<OpenPackScreen>
    with RewardScreenMixin {
  late List<AccountCard> _cards;
  late AnimationController _opacityAnimationController;

  @override
  void initState() {
    _cards = widget.args["achieveCards"];
    _cards = widget.args["achieveCards"] ??
        accountBloc.account!.cards.values.toList();
    _opacityAnimationController = AnimationController(
        vsync: this, upperBound: 3, duration: const Duration(seconds: 3));
    _opacityAnimationController.forward();
    super.initState();
  }

  @override
  Widget contentFactory() {
    var gap = 8.d;
    var len = _cards.length;
    var crossAxisCount = len < 4 ? len % 4 : 4;
    var mainAxisCount = (len / crossAxisCount).ceil();
    var itemSize = len < 2
        ? 430.d
        : len < 3
            ? 350.d
            : 240.d;
    return Widgets.button(
        padding: EdgeInsets.zero,
        child: Stack(alignment: const Alignment(0, -0.3), children: [
          backgrounBuilder(),
          SizedBox(
            width: itemSize * crossAxisCount + gap * crossAxisCount + 1,
            height: itemSize / CardItem.aspectRatio * mainAxisCount +
                (mainAxisCount + 1) * gap,
            child: GridView.builder(
              itemCount: _cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: CardItem.aspectRatio,
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: gap),
                itemBuilder: (c, i) => _cardItemBuilder(i, itemSize),
              ))
        ]),
        onPressed: () => Navigator.pop(context));
  }

  Widget _cardItemBuilder(int index, double size) {
    return AnimatedBuilder(
        animation: _opacityAnimationController,
        builder: (context, child) {
          return Opacity(
              opacity: (_opacityAnimationController.value - 2 + index * 0.1)
                  .clamp(0, 1),
              child: SizedBox(
                  width: size, child: CardItem(_cards[index], size: size)));
        });
  }
}
