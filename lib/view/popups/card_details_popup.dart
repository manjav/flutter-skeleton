import 'package:flutter/material.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../data/core/card.dart';
import '../../data/core/rpc.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/items/card_item.dart';
import '../../view/overlays/ioverlay.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/skinnedtext.dart';

class CardDetailsPopup extends AbstractPopup {
  const CardDetailsPopup({super.key, required super.args})
      : super(Routes.popupCardDetails);

  @override
  createState() => _CardPopupState();
}

class _CardPopupState extends AbstractPopupState<CardDetailsPopup> {
  late String _name;
  late Account _account;
  late AccountCard _card;

  @override
  void initState() {
    _card = widget.args['card'];
    _name = _card.fruit.name;
    _account = accountBloc.account!;
    super.initState();
  }

  @override
  contentFactory() {
    var siblings = _account.getReadyCards().where((c) => c.base == _card.base);
    var isUpgradable =
        (siblings.length > 1 || _card.base.isHero) && _card.isUpgradable;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(
          width: 360.d,
          child: CardItem(_card, size: 360.d, heroTag: "hero_${_card.id}")),
      SizedBox(height: 24.d),
      Text("${_name}_d".l(), style: TStyles.medium.copyWith(height: 2.7.d)),
      SizedBox(height: 48.d),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Column(children: [
          Widgets.skinnedButton(
            width: 370.d,
            label: "popupcardenhance".l(),
            padding: EdgeInsets.fromLTRB(8.d, 6.d, 8.d, 22.d),
            isEnable: _card.power < _card.base.get<int>(CardFields.powerLimit),
            onPressed: () => _onButtonsTap(Routes.popupCardEnhance),
            onDisablePressed: () => toast("card_max_power".l()),
          ),
          SizedBox(height: 16.d),
          Widgets.skinnedButton(
              padding: EdgeInsets.fromLTRB(8.d, 6.d, 8.d, 22.d),
              isEnable: isUpgradable,
              label: "popupcard${_card.base.isHero ? "upgrade" : "merge"}".l(),
              width: 370.d,
              onPressed: () => _onButtonsTap(_card.base.isHero
                  ? Routes.popupCardUpgrade
                  : Routes.popupCardMerge),
              onDisablePressed: () {
                toast(_card.isUpgradable
                    ? "card_no_sibling".l()
                    : "max_level".l(["${_name}_t".l()]));
              }),
        ]),
        Widgets.divider(height: 140.d, margin: 24.d, direction: Axis.vertical),
        Widgets.skinnedButton(
            color: ButtonColor.green,
            height: 160.d,
            isEnable: _card.fruit.isSalable,
            padding: EdgeInsets.fromLTRB(28.d, 18.d, 22.d, 28.d),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SkinnedText("card_sell".l(), style: TStyles.large),
              SizedBox(width: 20.d),
              Widgets.rect(
                padding: EdgeInsets.fromLTRB(0, 2.d, 10.d, 2.d),
                decoration: Widgets.imageDecore(
                    "ui_frame_inside", ImageCenterSliceData(42)),
                child: Row(children: [
                  Asset.load<Image>("icon_gold", height: 76.d),
                  SkinnedText(_card.basePrice.compact(),
                      style: TStyles.large.copyWith(height: 1)),
                ]),
              )
            ]),
            onPressed: () =>
                Overlays.insert(context, OverlayType.confirm, args: {
                  "message": "card_sell_warn".l([_card.basePrice.compact()]),
                  "onAccept": _sell
                }),
            onDisablePressed: () => toast("not_salable".l()))
      ])
    ]);
  }

  _onButtonsTap(Routes route) async {
    await Navigator.pushNamed(context, route.routeName,
        arguments: {"card": _card});
    setState(() {});
  }

  _sell() async {
    try {
      await rpc(RpcId.auctionSell, params: {RpcParams.card_id.name: _card.id});
      _account.buildings[Buildings.auction]!.map["cards"].add(_card);
      if (!mounted) return;
      accountBloc.add(SetAccount(account: _account));
      Navigator.pop(context);
    } finally {}
  }
}
