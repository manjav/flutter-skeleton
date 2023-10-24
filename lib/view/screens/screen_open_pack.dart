import 'package:flutter/material.dart';

import '../../data/core/fruit.dart';
import '../../services/deviceinfo.dart';
import '../../view/items/card_item.dart';
import '../route_provider.dart';
import '../widgets.dart';
import 'iscreen.dart';

class OpenPackScreen extends AbstractScreen {
  OpenPackScreen({required super.args, super.key}) : super(Routes.openPack);

  @override
  createState() => _OpenPackScreenState();
}

class _OpenPackScreenState extends AbstractScreenState<OpenPackScreen> {
  late List<AccountCard> _cards;
  @override
  List<Widget> appBarElementsLeft() => [];
  @override
  List<Widget> appBarElementsRight() => [];

  @override
  void initState() {
    _cards = widget.args["achieveCards"];
    super.initState();
  }

  @override
  Widget contentFactory() {
    var gap = 8.d;
    var len = _cards.length;
    var crossAxisCount = len < 4 ? len % 4 : 4;
    var mainAxisCount = (len / crossAxisCount).ceil();
    var itemSize = len < 2
        ? 438.d
        : len < 3
            ? 360.d
            : 250.d;
    return Widgets.button(
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: SizedBox(
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
              itemBuilder: (c, i) => _cardItemBuilder(_cards[i], itemSize),
            )),
        onPressed: () => Navigator.pop(context));
  }

  Widget _cardItemBuilder(AccountCard card, double size) {
    return SizedBox(width: size, child: CardItem(card, size: size));
  }
}
