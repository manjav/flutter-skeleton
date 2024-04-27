import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../app_export.dart';

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
          return Row(
            children: [
              Expanded(
                child: Container(
                  color: TColors.black25,
                  padding: EdgeInsets.symmetric(vertical: 20.d),
                  child: PageView.builder(
                    clipBehavior: Clip.hardEdge,
                    onPageChanged: (index) =>
                        onFocus(index, items.value[index]!),
                    controller: pageController,
                    itemCount: items.value.length,
                    itemBuilder: (BuildContext context, int index) =>
                        _cardBuilder(context, index, size),
                  ),
                ),
              ),
              SizedBox(
                width: 25.d,
              ),
              Widgets.touchable(
                context,
                // onTap: () => _onCardTap(context, index, item),
                child: Widgets.rect(
                  height: 180.d,
                  width: 180.d,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Asset.load<Image>("button_battle_back",
                          height: 180.d, width: 180.d),
                      Asset.load<Image>("button_battle",
                          height: 160.d, width: 160.d),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 25.d,
              ),
            ],
          );
        },
      ),
    );
  }

  _cardBuilder(BuildContext context, int index, double size) {
    var item = items.value[index]!;
    return Widgets.button(
      context,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(right: 10.d),
      onPressed: () => _onCardTap(context, index, item),
      child: CardItem(item,
          size: size,
          key: getGlobalKey(item.id),
          showCooldown: false,
          showCoolOff: true),
    );
    // var delta = 1.0,
    //     normal = 1.0,
    //     angle = 0.0,
    //     scale = 1.0,
    //     deltaX = 0.0,
    //     deltaY = 0.0;
    // return AnimatedBuilder(
    //     animation: pageController,
    //     builder: (context, child) {
    //       if (pageController.position.haveDimensions) {
    //         delta = (pageController.page! - index);
    //         angle = delta / (Localization.isRTL ? 10 : -10);
    //         normal = (delta.abs() / 3).clamp(0, 1);
    //         scale = 1 - Curves.easeInCirc.transform(normal);
    //         deltaX = Curves.easeInSine.transform(normal) *
    //             (delta > 0 ? 190.d : -190.d);
    //         deltaY = Curves.easeInExpo.transform(normal) * 820.d;
    //       }
    //       var item = items.value[index]!;
    //       return Transform.translate(
    //         offset: Offset(deltaX, deltaY),
    //         child: Transform.rotate(
    //           angle: angle,
    //           child: Transform.scale(
    //             scale: scale,
    //             child: Opacity(
    //               opacity: 1 - normal,
    //               child: Widgets.button(context,
    //                   padding: EdgeInsets.zero,
    //                   onPressed: () => _onCardTap(context, index, item),
    //                   child: CardItem(item,
    //                       size: size,
    //                       key: getGlobalKey(item.id),
    //                       showCooldown: false,
    //                       showCoolOff: true)),
    //             ),
    //           ),
    //         ),
    //       );
    //     });
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
