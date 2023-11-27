import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/fruit.dart';
import '../../data/core/infra.dart';
import '../../data/core/rpc.dart';
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

class HeroEvolvePopup extends AbstractPopup {
  const HeroEvolvePopup({super.key, required super.args})
      : super(Routes.popupHeroEvolve);

  @override
  createState() => _HeroEvolvePopupState();
}

class _HeroEvolvePopupState extends AbstractPopupState<HeroEvolvePopup> {
  @override
  List<Widget> appBarElements() {
    return [
      Indicator(widget.type.name, Values.gold),
      Indicator(widget.type.name, Values.nectar, width: 300.d),
      Indicator(widget.type.name, Values.potion, width: 280.d),
    ];
  }

  @override
  String titleBuilder() => "evolve_l".l();

  @override
  Widget contentFactory() {
    return BlocBuilder<AccountBloc, AccountState>(builder: (context, state) {
      var hero = state.account.heroes[(widget.args['card'] as AccountCard).id]!;
      var capacity = hero.card.base.potionLimit;
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
                  Asset.load<Image>("icon_potion", height: 64.d),
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
          onPressed: () => _evolve(account, hero));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Widgets.skinnedButton(
            color: ButtonColor.yellow,
            label: "+$step",
            icon: "icon_potion",
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
                    "frame_hatch_button", ImageCenterSliceData(42)),
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
    if (account.potion < step) {
      Navigator.pushNamed(context, Routes.popupPotion.routeName);
    } else {
      hero.fillPotion(context, step);
    }
  }

  _evolve(Account account, HeroCard hero) async {
    try {
      var result = await rpc(RpcId.evolveCard,
          params: {RpcParams.sacrifices.name: "[${hero.card.id}]"});
      account.cards.remove(hero.card.id);
      if (mounted) {
        account.update(context, result);
      }

      // Replace hero
      AccountCard card = result["card"];
      var newHero = HeroCard(card, 0);
      newHero.items = hero.items;
      account.heroes[card.id] = newHero;

      if (mounted) {
        accountBloc.add(SetAccount(account: account));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } finally {}
  }
}
