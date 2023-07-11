import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/rpc_data.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
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
  final List<AccountCard?> _selectedCards = List.generate(5, (index) => null);
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
                    _cardItemBuilder(c, i, cards[i], itemSize))),
        Positioned(
            top: paddingTop,
            right: 16.d,
            height: headerSize,
            left: 16.d,
            child: _header()),
        Positioned(
            width: 600.d,
            height: 214.d,
            bottom: 24.d,
            child: Widgets.labeledButton(
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const LoaderWidget(AssetType.image, "icon_battle"),
                    SkinnedText("battle_start".l(),
                        style: TStyles.large.copyWith(height: 1.7)),
                  ],
                ),
                size: ""))
      ]);
    });
  }

  Widget? _cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.button(
      foregroundDecoration: _selectedCards.contains(card)
          ? BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(28.d)),
              border: Border.all(color: TColors.white, width: 8.d))
          : null,
      padding: EdgeInsets.zero,
      onPressed: () {
        if (_addCard(card)) setState(() {});
      },
      child: CardView(card, size: itemSize, key: card.key),
    );
  }

  bool _addCard(card) {
    var index = _selectedCards.indexOf(card);
    if (index > -1) {
      _selectedCards[index] = null;
      return true;
    }
    for (var i = 0; i < _selectedCards.length; i++) {
      if (i != 2 && _selectedCards[i] == null || i == 4) {
        _selectedCards[i] = card;
        return true;
      }
    }
    return false;
  }

  Widget _header() {
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
        padding: EdgeInsets.fromLTRB(28.d, 12.d, 28.d, 32.d),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                  height: 168.d,
                  child: Row(
                    children: [
                      _avatar(TextAlign.left),
                      SizedBox(width: 8.d),
                      _opponentInfo(
                          CrossAxisAlignment.start, "You", _calculatePower()),
                      Expanded(
                          child: Asset.load<Image>("deck_battle_icon",
                              height: 136.d)),
                      _opponentInfo(CrossAxisAlignment.end, "Enemy", "110~130"),
                      SizedBox(width: 8.d),
                      _avatar(TextAlign.right),
                    ],
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < _selectedCards.length; i++) _cardHolder(i)
                ],
              ),
            ]));
  }

  Widget _avatar(TextAlign align) {
    return SizedBox(
        width: 160.d,
        height: 160.d,
        child: LevelIndicator(key: GlobalKey(), align: align));
  }

  Widget _opponentInfo(CrossAxisAlignment align, String name, String power) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: align,
      children: [
        SkinnedText(name,
            style: TStyles.small.copyWith(
                height: 0.8, color: TColors.primary10, fontSize: 36.d)),
        SkinnedText(power, style: TStyles.medium.copyWith(height: 0.8)),
        SizedBox(height: 16.d)
      ],
    );
  }

  Widget _cardHolder(int index) {
    var card = _selectedCards[index];
    var balloonData =
        ImageCenterSliceDate(50, 57, const Rect.fromLTWH(28, 19, 2, 2));
    var slicingData = ImageCenterSliceDate(117, 117);
    return Column(children: [
      card == null
          ? const SizedBox()
          : Widgets.rect(
              padding: EdgeInsets.all(12.d),
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      centerSlice: balloonData.centerSlice,
                      image: Asset.load<Image>(
                        "deck_balloon",
                        centerSlice: balloonData,
                      ).image)),
              child: Text(card.power.compact(), style: TStyles.mediumInvert)),
      Widgets.button(
          onPressed: () => setState(() {
                _selectedCards[index] = null;
              }),
          width: index == 2 ? 202.d : 184.d,
          height: index == 2 ? 202.d : 184.d,
          padding: EdgeInsets.all(12.d),
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fill,
                  centerSlice: slicingData.centerSlice,
                  image: Asset.load<Image>(
                    "deck_placeholder",
                    centerSlice: slicingData,
                  ).image)),
          child: _selectedCards[index] == null
              ? _emptyCard(index)
              : _filledCard(_selectedCards[index]!))
    ]);
  }

  Widget _emptyCard(int index) {
    return Padding(
        padding: EdgeInsets.all(24.d),
        child: Asset.load<Image>(
            "deck_placeholder_${index == 2 ? 'hero' : 'card'}"));
  }

  Widget _filledCard(AccountCard accountCard) {
    return LoaderWidget(
        AssetType.image, accountCard.base.get<String>(CardFields.name),
        subFolder: "cards");
  }

  String _calculatePower() {
    var power = 0;
    for (var card in _selectedCards) {
      power += card != null ? card.power : 0;
    }
    return power.compact();
  }
}
