import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../view/items/card_item.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';

class CardDetailsPopup extends AbstractPopup {
  const CardDetailsPopup({super.key, required super.args})
      : super(Routes.popupCardDetails);

  @override
  createState() => _CardPopupState();
}

class _CardPopupState extends AbstractPopupState<CardDetailsPopup> {
  late AccountCard _card;
  late FruitData _fruit;
  late String _name;

  @override
  void initState() {
    _card = widget.args['card'];
    _fruit = _card.base.get<FruitData>(CardFields.fruit);
    _name = _fruit.get<String>(FriutFields.name);
    super.initState();
  }

  @override
  titleBuilder() => "${_name}_t".l();

  @override
  contentFactory() {
    var siblings = BlocProvider.of<AccountBloc>(context)
        .account!
        .getReadyCards()
        .where((c) => c.base == _card.base);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 360.d, child: CardItem(_card, size: 360.d)),
        SizedBox(height: 24.d),
        Text("${_name}_d".l(), style: TStyles.medium.copyWith(height: 2.7.d)),
        SizedBox(height: 48.d),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Widgets.labeledButton(
                    label: "card_enhance".l(),
                    width: 370.d,
                    onPressed: () => _onButtonsTap(Routes.popupCardEnhance)),
                SizedBox(height: 16.d),
                Widgets.labeledButton(
                    isEnable: siblings.length > 1,
                    label: "card_merge".l(),
                    width: 370.d,
                    onPressed: () => _onButtonsTap(Routes.popupCardMerge)),
              ],
            ),
            Widgets.divider(
                height: 140.d, margin: 48.d, direction: Axis.vertical),
            Widgets.labeledButton(
                label: "card_sell".l(),
                color: ButtonColor.green,
                width: 370.d,
                onPressed: () => _onButtonsTap(Routes.popupCardMerge)),
          ],
        ),
      ],
    );
  }

  _onButtonsTap(Routes route) async {
    await Navigator.pushNamed(context, route.routeName,
        arguments: {"card": _card});
    setState(() {});
  }
}
