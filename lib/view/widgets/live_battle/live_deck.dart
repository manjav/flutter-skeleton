import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/core/card.dart';
import '../../../services/deviceinfo.dart';
import '../../items/card_item.dart';
import '../../widgets.dart';

class LiveDeck extends StatelessWidget {
  final List<AccountCard> items;
  final PageController pageController;
  final Function(int, AccountCard) onPageChanged;
  const LiveDeck(this.pageController, this.items, this.onPageChanged,
      {super.key});

  @override
  Widget build(BuildContext context) {
    var size = pageController.viewportFraction * DeviceInfo.size.width;
    return Positioned(
        bottom: 200.d,
        left: 0,
        right: 0,
        height: size / CardItem.aspectRatio,
        child: PageView.builder(
          clipBehavior: Clip.none,
          onPageChanged: (index) => onPageChanged(index, items[index]),
          controller: pageController,
          itemCount: items.length,
          itemBuilder: (BuildContext context, int index) =>
              _cardBuilder(context, index, size),
        ));
  }

  _cardBuilder(BuildContext context, int index, double size) {
    var delta = 1.0,
        normal = 1.0,
        angle = 0.0,
        scale = 1.0,
        deltaX = 0.0,
        deltaY = 0.0;
    return AnimatedBuilder(
        animation: pageController,
        builder: (context, child) {
          if (pageController.position.haveDimensions) {
            delta = (pageController.page! - index);
            angle = delta / -10;
            normal = (delta.abs() / 3).clamp(0, 1);
            scale = 1 - Curves.easeInCirc.transform(normal);
            deltaX = Curves.easeInSine.transform(normal) *
                (delta > 0 ? 190.d : -190.d);
            deltaY = Curves.easeInExpo.transform(normal) * 820.d;
          }
          var item = items.value[index]!;
          return Transform.translate(
            offset: Offset(deltaX, deltaY),
            child: Transform.rotate(
              angle: angle,
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: 1 - normal,
                  child: Widgets.button(
                      padding: EdgeInsets.zero,
                      onPressed: () => _onCardTap(context, index),
                      child: CardItem(items[index],
                          size: size, showCooldown: false, showCooloff: true)),
                ),
              ),
            ),
          );
        });
  }

  _onCardTap(BuildContext context, int index) {
    if (pageController.page == index) {
      if (items[index].getRemainingCooldown() > 0) {
        items[index].coolOff(context);
      }
      return;
    }
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }
}
