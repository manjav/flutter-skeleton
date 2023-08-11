import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/building.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../items/card_item.dart';
import '../key_provider.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/card_holder.dart';
import 'ipopup.dart';

class CardSelectPopup extends AbstractPopup {
  const CardSelectPopup({super.key, required super.args})
      : super(Routes.popupCardSelect);

  @override
  createState() => _CardSelectPopupState();
}

class _CardSelectPopupState extends AbstractPopupState<CardSelectPopup>
    with KeyProvider {
  final _selectedCards = SelectedCards([]);
  late Building _building;

  @override
  void initState() {
    _building = widget.args['building'];
    _selectedCards.value = [..._building.cards];
    contentPadding = EdgeInsets.fromLTRB(40.d, 210.d, 40.d, 88.d);
    super.initState();
  }

  @override
  titleBuilder() => "card_select".l();

  @override
  Widget contentFactory() {
    var gap = 10.d;
    var crossAxisCount = 4;
    var itemSize =
        (DeviceInfo.size.width - gap * (crossAxisCount + 1)) / crossAxisCount;
    var exceptions = [
      Buildings.defense,
      Buildings.mine,
      Buildings.auction,
      Buildings.offense
    ]..remove(_building.type);
    var cards = BlocProvider.of<AccountBloc>(context)
        .account!
        .getReadyCards(exceptions: exceptions);
    return ValueListenableBuilder<List<AccountCard?>>(
        valueListenable: _selectedCards,
        builder: (context, value, child) {
          return SizedBox(
              width: 980.d,
              height: 1080.d,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                      top: 222.d,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: GridView.builder(
                          itemCount: cards.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 0.74,
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: gap,
                                  mainAxisSpacing: gap),
                          itemBuilder: (c, i) =>
                              _cardItemBuilder(c, i, cards[i], itemSize))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < _selectedCards.value.length; i++)
                        CardHolder(
                            card: _selectedCards.value[i],
                            showPower: false,
                            onTap: () => _selectedCards.setAtCard(i, null)),
                    ],
                  ),
                  Positioned(
                      width: 420.d,
                      height: 160.d,
                      bottom: 24.d,
                      child: Widgets.skinnedButton(
                          label: "card_select".l(),
                          onPressed: () =>
                              Navigator.pop(context, _selectedCards.value)))
                ],
              ));
        });
  }

  Widget? _cardItemBuilder(
      BuildContext context, int index, AccountCard card, double itemSize) {
    return Widgets.button(
      padding: EdgeInsets.zero,
      foregroundDecoration: _selectedCards.value.contains(card)
          ? BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(28.d)),
              border: Border.all(color: TColors.primary10, width: 10.d))
          : null,
      onPressed: () => _selectedCards.setCard(card),
      child: CardItem(card,
          inDeck: true, size: itemSize, key: getGlobalKey(card.id)),
    );
  }
}
