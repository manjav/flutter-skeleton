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
  late String _name;

  @override
  void initState() {
    _card = widget.args['card'];
    _name = _card.fruit.get<String>(FriutFields.name);
    super.initState();
  }

  @override
  contentFactory() {
    var siblings = BlocProvider.of<AccountBloc>(context)
        .account!
        .getReadyCards()
        .where((c) => c.base == _card.base);
    var isUpgradable =
        (siblings.length > 1 || _card.base.isHero) && _card.isUpgradable;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            width: 360.d,
            child: CardItem(_card, size: 360.d, heroTag: "hero_${_card.id}")),
        SizedBox(height: 24.d),
        Text("${_name}_d".l(), style: TStyles.medium.copyWith(height: 2.7.d)),
        SizedBox(height: 48.d),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Widgets.skinnedButton(
                  width: 370.d,
                  label: "popupcardenhance".l(),
                  padding: EdgeInsets.fromLTRB(8.d, 6.d, 8.d, 22.d),
                  isEnable:
                      _card.power < _card.base.get<int>(CardFields.powerLimit),
                  onPressed: () => _onButtonsTap(Routes.popupCardEnhance),
                  onDisablePressed: () => toast("card_max_power".l()),
                ),
                SizedBox(height: 16.d),
                Widgets.skinnedButton(
                  padding: EdgeInsets.fromLTRB(8.d, 6.d, 8.d, 22.d),
                  isEnable: isUpgradable,
                  label:
                      "popupcard${_card.base.isHero ? "upgrade" : "merge"}".l(),
                  width: 370.d,
                  onPressed: () => _onButtonsTap(_card.base.isHero
                      ? Routes.popupCardUpgrade
                      : Routes.popupCardMerge),
                  onDisablePressed: () {
                    toast(_card.isUpgradable
                        ? "card_no_sibling".l()
                        : "max_level".l(["${_name}_t".l()]));
                  },
                ),
              ],
            ),
            Widgets.divider(
                height: 140.d, margin: 48.d, direction: Axis.vertical),
            Widgets.skinnedButton(
              width: 370.d,
              isEnable: false,
              label: "card_sell".l(),
              color: ButtonColor.green,
              padding: EdgeInsets.fromLTRB(8.d, 6.d, 8.d, 22.d),
              onPressed: () => _onButtonsTap(Routes.popupCardMerge),
              onDisablePressed: () => toast("coming_soon".l()),
            ),
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
