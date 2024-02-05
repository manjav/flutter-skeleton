import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_export.dart';

class CardsPageItem extends AbstractPageItem {
  const CardsPageItem({super.key}) : super("cards");

  @override
  createState() => _CardsPageItemState();
}

class _CardsPageItemState extends AbstractPageItemState<AbstractPageItem>
    with KeyProvider {
  @override
  Widget build(BuildContext context) {
    var gap = 10.d;
    var crossAxisCount = 4;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    return Consumer<AccountProvider>(builder: (_, state, child) {
      var cards = state.account.getReadyCards();
      var paddingTop = MediaQuery.of(context).viewPadding.top;
      if (paddingTop <= 0) {
        paddingTop = 24.d;
      }
      return Stack(children: [
        GridView.builder(
            itemCount: cards.length,
            padding: EdgeInsets.fromLTRB(gap, paddingTop + 150.d, gap, 210.d),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: CardItem.aspectRatio,
                crossAxisCount: 4,
                crossAxisSpacing: gap,
                mainAxisSpacing: gap),
            itemBuilder: (c, i) => cardItemBuilder(c, i, cards[i], itemSize)),
        PositionedDirectional(
            top: paddingTop,
            start: 20.d,
            width: 132.d,
            child: SkinnedButton(
                icon: "icon_collection",
                onPressed: () =>
                    serviceLocator<RouteService>().to(Routes.popupCollection))),
        PositionedDirectional(
            top: paddingTop,
            width: 132.d,
            start: 150.d,
            child: SkinnedButton(
                icon: "icon_combo",
                onPressed: () {
                  // Show unavailable message
                  var levels =
                      state.account.loadingData.rules["availabilityLevels"]!;
                  if (state.account.level < levels["combo"]) {
                    Overlays.insert(
                        context,
                        ToastOverlay(
                          "unavailable_l"
                              .l(["popupcombo".l(), levels["combo"]]),
                        ));
                  } else {
                    serviceLocator<RouteService>().to(Routes.popupCombo);
                  }
                }))
      ]);
    });
  }

  Widget? cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.touchable(
      context,
      onTap: () => serviceLocator<RouteService>()
          .to(Routes.popupCardDetails, args: {'card': card}),
      child: CardItem(card,
          size: itemSize,
          key: getGlobalKey(card.id),
          heroTag: "hero_${card.id}"),
    );
  }
}
