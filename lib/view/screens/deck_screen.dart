import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/rpc_data.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/screens/iscreen.dart';
import '../../view/widgets/level_indicator.dart';
import '../../view/widgets/skinnedtext.dart';
import '../items/card_item.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/loaderwidget.dart';

class DeckScreen extends AbstractScreen {
  DeckScreen({super.key}) : super(Routes.deck);

  @override
  createState() => _DeckScreenState();
}

class _DeckScreenState extends AbstractScreenState<AbstractScreen> {
  @override
  Widget contentFactory() {
    var paddingTop = 172.d;
    var headerSize = 509.d;
    var gap = 10.d;
    var crossAxisCount = 4;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var cards = state.account.get<List<AccountCard>>(AccountField.cards);
      cards.sort((AccountCard a, AccountCard b) => b.power - a.power);
      return Stack(alignment: Alignment.bottomCenter, children: [
        Positioned(
            top: paddingTop + headerSize,
            right: 0,
            bottom: 0,
            left: 0,
            child: GridView.builder(
                padding: EdgeInsets.fromLTRB(gap, gap, gap, 270.d),
                itemCount: cards.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.74,
                    crossAxisCount: 4,
                    crossAxisSpacing: gap,
                    mainAxisSpacing: gap),
                itemBuilder: (c, i) =>
                    cardItemBuilder(c, i, cards[i], itemSize))),
        Positioned(
            top: paddingTop,
            right: 16.d,
            height: headerSize,
            left: 16.d,
            child: _header()),
        Positioned(
            width: 600.d,
            height: 220.d,
            bottom: 24.d,
            child: Widgets.labeledButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const LoaderWidget(AssetType.image, "icon_battle"),
                    SkinnedText("battle_start".l(), style: TStyles.large),
                  ],
                ),
                size: ""))
      ]);
    });
  }

  Widget? cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.touchable(
      onTap: () => Navigator.pushNamed(context, Routes.popupCard.routeName,
          arguments: {'card': card}),
      child: CardView(card, size: itemSize, key: card.key),
    );
  }

  GlobalKey k = GlobalKey();
  _header() {
    var slicingData = ImageCenterSliceDate(117, 509);
    return Widgets.rect(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.fill,
                centerSlice: slicingData.centerSlice,
                image: Asset.load<Image>(
                  "deck_header",
                  centerSlice: slicingData,
                ).image)),
        child: Column(children: [
          Widgets.rect(
              height: 190.d,
              padding: EdgeInsets.symmetric(horizontal: 36.d, vertical: 12.d),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: 160.d,
                      height: 160.d,
                      child: LevelIndicator(key: k)),
                  Asset.load<Image>("deck_battle_icon", width: 139.d),
                ],
              ))
        ]));
  }
}
