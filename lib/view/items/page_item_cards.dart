import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/fruit.dart';
import '../../mixins/key_provider.dart';
import '../../services/device_info.dart';
import '../../services/localization.dart';
import '../../view/route_provider.dart';
import '../overlays/overlay.dart';
import '../widgets.dart';
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
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var cards = state.account.getReadyCards();
      return Stack(children: [
        GridView.builder(
            itemCount: cards.length,
            padding: EdgeInsets.fromLTRB(gap, 200.d, gap, 210.d),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: CardItem.aspectRatio,
                crossAxisCount: 4,
                crossAxisSpacing: gap,
                mainAxisSpacing: gap),
            itemBuilder: (c, i) => cardItemBuilder(c, i, cards[i], itemSize)),
        PositionedDirectional(
            top: 50.d,
            start: 20.d,
            width: 132.d,
            child: Widgets.skinnedButton(
                icon: "icon_collection",
                onPressed: () => Navigator.pushNamed(
                    context, Routes.popupCollection.routeName))),
        PositionedDirectional(
            top: 50.d,
            width: 132.d,
            start: 150.d,
            child: Widgets.skinnedButton(
                icon: "icon_combo",
                onPressed: () {
                  // Show unavailable message
                  if (state.account.level <
                      Account.availabilityLevels["tribe"]!) {
                    Overlays.insert(context, OverlayType.toast,
                        args: "unavailable_l".l([
                          "popupcombo".l(),
                          Account.availabilityLevels["combo"]
                        ]));
                  } else {
                    Navigator.pushNamed(context, Routes.popupCombo.routeName);
                  }
                }))
      ]);
    });
  }

  Widget? cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.touchable(
      onTap: () => Navigator.pushNamed(
          context, Routes.popupCardDetails.routeName,
          arguments: {'card': card}),
      child: CardItem(card,
          size: itemSize,
          key: getGlobalKey(card.id),
          heroTag: "hero_${card.id}"),
    );
  }
}
