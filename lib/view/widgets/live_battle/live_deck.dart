import 'package:flutter/material.dart';

import '../../../data/core/fruit.dart';
import '../../../mixins/key_provider.dart';
import '../../../services/deviceinfo.dart';
import '../../items/card_item.dart';
import '../../widgets.dart';
import '../card_holder.dart';

class LiveDeck extends StatelessWidget with KeyProvider {
  final SelectedCards items;
  final PageController pageController;
  final Function(int, AccountCard) onFocus;
  final Function(int, AccountCard) onSelect;

  LiveDeck(this.pageController, this.items, this.onFocus, this.onSelect,
      {super.key});

  @override
  Widget build(BuildContext context) {
    var size = pageController.viewportFraction * DeviceInfo.size.width;
    return Positioned(
      bottom: 200.d,
      left: 0,
      right: 0,
      height: size / CardItem.aspectRatio,
      child: ValueListenableBuilder<List<AccountCard?>>(
          valueListenable: items,
          builder: (context, value, child) {
            return PageView.builder(
                clipBehavior: Clip.none,
                onPageChanged: (index) => onFocus(index, items.value[index]!),
                controller: pageController,
                itemCount: items.value.length,
                itemBuilder: (BuildContext context, int index) =>
                    _cardBuilder(context, index, size));
          }),
    );
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
                      onPressed: () => _onCardTap(context, index, item),
                      child: CardItem(item,
                          size: size,
                          key: getGlobalKey(item.id),
                          showCooldown: false,
                          showCooloff: true)),
                ),
              ),
            ),
          );
        });
  }

  _onCardTap(BuildContext context, int index, AccountCard item) {
    if (pageController.page == index) {
      if (item.getRemainingCooldown() > 0) {
        item.coolOff(context);
      } else {
        onSelect(index, item);
      }
    }
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }
}
