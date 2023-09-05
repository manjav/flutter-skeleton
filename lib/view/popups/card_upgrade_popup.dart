import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../data/core/rpc.dart';
import '../../services/connection/http_connection.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../view/popups/hero_popup.dart';
import '../items/card_item.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/indicator.dart';
import '../widgets/skinnedtext.dart';
import 'ipopup.dart';

class CardUpgradePopup extends AbstractPopup {
  const CardUpgradePopup({super.key, required super.args})
      : super(Routes.popupCardUpgrade);

  @override
  createState() => _CardUpgradePopupState();
}

class _CardUpgradePopupState extends AbstractPopupState<CardUpgradePopup> {
  @override
  List<Widget> appBarElements() {
    return [
      Indicator(widget.type.name, AccountField.gold),
      Indicator(widget.type.name, AccountField.nectar, width: 300.d),
      Indicator(widget.type.name, AccountField.potion_number, width: 280.d),
    ];
  }

  @override
  Widget contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var hero = state.account.get<Map<int, HeroCard>>(
          AccountField.heroes)[(widget.args['card'] as AccountCard).id]!;
      var capacity = hero.card.base.get<int>(CardFields.potion_limit);
      return SizedBox(
          width: 960.d,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 320.d,
                child: CardItem(hero.card,
                    size: 320.d,
                    showCooldown: false,
                    extraPower:
                        hero.card.getNextLevelPower() - hero.card.power),
              ),
              SizedBox(height: 32.d),
              HeroPopup.attributesBuilder(hero, hero.getNextLevelAttributes()),
              SizedBox(height: 32.d),
              Text("hero_upgrade_description".l(),
                  style: TStyles.medium.copyWith(height: 1.2)),
              Widgets.divider(margin: 36.d, width: 700.d),
              Widgets.slider(
                0,
                hero.potion.toDouble(),
                capacity.toDouble(),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Asset.load<Image>("icon_potion_number", height: 64.d),
                  SizedBox(width: 12.d),
                  SkinnedText(
                      "${hero.potion.compact()} / ${capacity.compact()}")
                ]),
                width: 700.d,
              ),
              SizedBox(height: 50.d),
              _buttons(state.account, hero, capacity)
            ],
          ));
    });
  }

  _buttons(Account account, HeroCard hero, int capacity) {
    int price = ((capacity - hero.potion) * HeroCard.evolveBaseNectar).round();
    var step = 50;

    if (hero.potion >= capacity) {
      return Widgets.skinnedButton(
          width: 500.d,
          color: ButtonColor.green,
          label: titleBuilder(),
          onPressed: () => _upgrade(account, hero));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Widgets.skinnedButton(
            color: ButtonColor.yellow,
            label: "+$step",
            icon: "icon_potion_number",
            onPressed: () => _fill(account, hero, step)),
        SizedBox(width: 10.d),
        Widgets.skinnedButton(
            color: ButtonColor.teal,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SkinnedText("fillout_l".l(), style: TStyles.large),
              SizedBox(width: 16.d),
              Widgets.rect(
                padding: EdgeInsets.only(right: 12.d),
                decoration: Widgets.imageDecore(
                    "ui_frame_inside", ImageCenterSliceData(42, 42)),
                child: Row(children: [
                  Asset.load<Image>("icon_nectar", height: 72.d),
                  SkinnedText(price.compact(), style: TStyles.large),
                ]),
              )
            ]),
            onPressed: () => _fill(account, hero, 0)),
      ],
    );
  }

  void _fill(Account account, HeroCard hero, int step) {
    if (account.get<int>(AccountField.potion_number) < step) {
      Navigator.pushNamed(context, Routes.popupPotion.routeName);
    } else {
      hero.fillPotion(context, step);
    }
  }

  _upgrade(Account account, HeroCard hero) async {
    try {
      var result = await BlocProvider.of<ServicesBloc>(context)
          .get<HttpConnection>()
          .tryRpc(context, RpcId.evolveCard,
              params: {RpcParams.sacrifices.name: "[${hero.card.id}]"});
      account.getCards().remove(hero.card.id);
      account.update(result);

      // Replace hero
      var heroes = account.get<Map<int, HeroCard>>(AccountField.heroes);
      AccountCard card = result["card"];
      var newHero = HeroCard(card, 0);
      newHero.items = hero.items;
      heroes[card.id] = newHero;
      heroes.remove(hero.card.id);

      if (mounted) {
        BlocProvider.of<AccountBloc>(context).add(SetAccount(account: account));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } finally {}
  }
}
