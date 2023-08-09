import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../view/items/page_item.dart';
import '../../view/route_provider.dart';
import '../key_provider_mixin.dart';
import '../widgets.dart';
import 'card_item.dart';

class CardsPageItem extends AbstractPageItem {
  const CardsPageItem({super.key}) : super("cards");
  @override
  createState() => _MainMapItemState();
}

class _MainMapItemState extends AbstractPageItemState<AbstractPageItem>
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
                childAspectRatio: 0.74,
                crossAxisCount: 4,
                crossAxisSpacing: gap,
                mainAxisSpacing: gap),
            itemBuilder: (c, i) => cardItemBuilder(c, i, cards[i], itemSize)),
        Positioned(
            left: 12.d,
            top: 28.d,
            width: 132.d,
            child: Widgets.skinnedButton(
                icon: "icon_collection",
                onPressed: () => Navigator.pushNamed(
                    context, Routes.popupCollection.routeName))),
        Positioned(
            left: 144.d,
            top: 28.d,
            width: 132.d,
            child: Widgets.skinnedButton(
                icon: "icon_combo",
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.popupCombo.routeName))),
        Positioned(
            left: 276.d,
            top: 28.d,
            width: 132.d,
            child: Widgets.skinnedButton(
                icon: "icon_hero",
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.popupHero.routeName)))
      ]);
    });
  }

  Widget? cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.touchable(
      onTap: () => Navigator.pushNamed(
          context, Routes.popupCardDetails.routeName,
          arguments: {'card': card}),
      child: CardItem(card, size: itemSize, key: getGlobalKey(card.id)),
    );
  }
}
