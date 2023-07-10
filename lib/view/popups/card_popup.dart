import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/deviceinfo.dart';
import 'package:flutter_skeleton/services/localization.dart';
import 'package:flutter_skeleton/services/theme.dart';

import '../../data/core/rpc_data.dart';
import '../../view/items/card_item.dart';
import '../../view/popups/ipopup.dart';
import '../widgets.dart';

class CardDetailsPopup extends AbstractPopup {
  const CardDetailsPopup(super.type, {super.key, required super.args});

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
        SizedBox(width: 360.d, child: CardView(_card, size: 360.d)),
        SizedBox(height: 24.d),
        Text("${_name}_d".l(), style: TStyles.medium.copyWith(height: 2.7.d)),
        SizedBox(height: 48.d),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Widgets.labeledButton(lable: "card_enhance".l(), width: 370.d),
                SizedBox(height: 16.d),
                Widgets.labeledButton(lable: "card_evolve".l(), width: 370.d),
              ],
            ),
            Widgets.verticalDivider(height: 140.d, margin: 48.d),
            Widgets.labeledButton(
                lable: "card_sell".l(), color: "green", width: 370.d),
          ],
        ),
        SizedBox(height: 48.d),
      ],
    );
  }
}
