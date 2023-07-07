import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/rpc_data.dart';
import '../../services/deviceinfo.dart';
import '../../view/items/card_view.dart';
import '../../view/items/page_item.dart';

class CardsPageItem extends AbstractPageItem {
  const CardsPageItem({super.key}) : super("cards");
  @override
  createState() => _MainMapItemState();
}

class _MainMapItemState extends AbstractPageItemState<AbstractPageItem> {
  @override
  Widget build(BuildContext context) {
    var gap = 10.d;
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var cards = state.account.get<List<AccountCard>>(AccountField.cards);
      return Stack(children: [
        GridView.builder(
            itemCount: cards.length,
            padding: EdgeInsets.fromLTRB(gap, 300.d, gap, 210.d),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.74,
                crossAxisCount: 4,
                crossAxisSpacing: gap,
                mainAxisSpacing: gap),
            itemBuilder: (c, i) => cardItemBuilder(c, i, cards[i])),
      ]);
    });
  }

  Widget? cardItemBuilder(BuildContext context, int index, AccountCard card) {
    return CardView(card);
  }
}
