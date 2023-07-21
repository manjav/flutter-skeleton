import 'package:flutter/material.dart';

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
                Widgets.labeledButton(label: "card_enhance".l(), width: 370.d),
                SizedBox(height: 16.d),
                Widgets.labeledButton(label: "card_evolve".l(), width: 370.d),
              ],
            ),
            Widgets.divider(
                height: 140.d, margin: 48.d, direction: Axis.vertical),
            Widgets.labeledButton(
                label: "card_sell".l(), color: "green", width: 370.d),
          ],
        ),
        SizedBox(height: 48.d),
      ],
    );
  }
}
