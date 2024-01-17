import 'package:flutter/material.dart';

import '../../app_export.dart';

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
    _account = accountProvider.account;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var siblings = _account.getReadyCards().where((c) => c.base == _card.base);
    var isUpgradable =
        (siblings.length > 1 || _card.base.isHero) && _card.isUpgradable;
    return SafeArea(
        child: Scaffold(
            backgroundColor: backgroundColor,
            body: Stack(children: [
              Widgets.touchable(context,
                  onTap:
                      barrierDismissible ? () => Navigator.pop(context) : null),
              Container(
                  alignment: alignment,
                  padding: EdgeInsets.all(100.d),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                        width: 500.d,
                        child: CardItem(_card,
                            size: 500.d, heroTag: "hero_${_card.id}")),
                    SizedBox(height: 70.d),
                    Text("${_name}_description".l(),
                        style: TStyles.mediumInvert.copyWith(height: 2.7.d)),
                    SizedBox(height: 100.d),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _button(
                        width: 420.d,
                        label: "˧  ${"enhance_l".l()}",
                        isEnable: _card.power < _card.base.powerLimit,
                        onPressed: () => _onButtonsTap(Routes.popupCardEnhance),
                        onDisablePressed: () => toast("card_max_power".l()),
                      ),
                      _button(
                          width: 420.d,
                          isEnable: isUpgradable,
                          label: "˨  ${"evolve_l".l()}",
                          onPressed: () => _onButtonsTap(_card.base.isHero
                              ? Routes.popupHeroEvolve
                              : Routes.popupCardEvolve),
                          onDisablePressed: () {
                            toast(_card.isUpgradable
                                ? "card_no_sibling".l()
                                : "max_level".l(["${_name}_t".l()]));
                          }),
                    ]),
                    _button(
                        isVisible: _card.fruit.isHero,
                        color: ButtonColor.violet,
                        label: "˩  ${"hero_edit".l()}",
                        onPressed: () => Routes.popupHero
                            .navigate(context, args: {"card": _card.fruit.id})),
                    _button(
                        isVisible: _card.fruit.isSalable,
                        color: ButtonColor.green,
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          SkinnedText("˫  ${"card_sell".l()}",
                              style: TStyles.large),
                          SizedBox(width: 20.d),
                          Widgets.rect(
                            padding: EdgeInsets.fromLTRB(0, 2.d, 10.d, 2.d),
                            decoration: Widgets.imageDecorator(
                                "frame_hatch_button", ImageCenterSliceData(42)),
                            child: Row(
                                textDirection: TextDirection.ltr,
                                children: [
                                  Asset.load<Image>("icon_gold", height: 76.d),
                                  SkinnedText(_card.basePrice.compact(),
                                      style: TStyles.large.copyWith(height: 1)),
                                ]),
                          )
                        ]),
                        onPressed: () => Overlays.insert(
                                context, OverlayType.confirm,
                                args: {
                                  "message": "card_sell_warn"
                                      .l([_card.basePrice.compact()]),
                                  "onAccept": _sell
                                }),
                        onDisablePressed: () => toast("not_salable".l()))
                  ]))
            ])));
  }

  Widget _button(
      {bool isVisible = true,
      bool isEnable = true,
      Function()? onPressed,
      Function()? onDisablePressed,
      String? icon,
      String? label,
      ButtonColor color = ButtonColor.yellow,
      Widget? child,
      double width = 800}) {
    if (!isVisible) {
      return const SizedBox();
    }
    return Widgets.skinnedButton(context,
        margin: EdgeInsets.all(8.d),
        icon: icon,
        color: color,
        child: child,
        label: label,
        width: width,
        height: 160.d,
        isEnable: isEnable,
        onPressed: onPressed,
        onDisablePressed: onDisablePressed);
  }

  _onButtonsTap(Routes route) async {
    await route.navigate(context, args: {"card": _card});
    if (mounted && !accountProvider.account.cards.containsKey(_card.id)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    setState(() {});
  }

  _sell() async {
    try {
      await rpc(RpcId.auctionSell, params: {RpcParams.card_id.name: _card.id});
      _account.buildings[Buildings.auction]!.cards.add(_card);
      if (!mounted) return;
      accountProvider.update();
      Navigator.pop(context);
    } finally {}
  }
}