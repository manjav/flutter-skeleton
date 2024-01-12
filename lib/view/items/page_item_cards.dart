import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/core/fruit.dart';
import '../../skeleton/mixins/key_provider.dart';
import '../../providers/account_provider.dart';
import '../../skeleton/services/device_info.dart';
import '../../skeleton/services/localization.dart';
import '../../skeleton/services/routes.dart';
import '../../skeleton/views/overlays/overlay.dart';
import '../../skeleton/views/widgets.dart';
import 'card_item.dart';
import 'page_item.dart';

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
            child: Widgets.skinnedButton(context,
                icon: "icon_collection",
                onPressed: () => Routes.popupCollection.navigate(context))),
        PositionedDirectional(
            top: paddingTop,
            width: 132.d,
            start: 150.d,
            child: Widgets.skinnedButton(context, icon: "icon_combo",
                onPressed: () {
              // Show unavailable message
              var levels =
                  state.account.loadingData.rules["availabilityLevels"]!;
              if (state.account.level < levels["combo"]) {
                Overlays.insert(context, OverlayType.toast,
                    args:
                        "unavailable_l".l(["popupcombo".l(), levels["combo"]]));
              } else {
                Routes.popupCombo.navigate(context);
              }
            }))
      ]);
    });
  }

  Widget? cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.touchable(
      context,
      onTap: () =>
          Routes.popupCardDetails.navigate(context, args: {'card': card}),
      child: CardItem(card,
          size: itemSize,
          key: getGlobalKey(card.id),
          heroTag: "hero_${card.id}"),
    );
  }
}
