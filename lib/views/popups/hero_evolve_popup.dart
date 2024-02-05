import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_export.dart';

class HeroEvolvePopup extends AbstractPopup {
  const HeroEvolvePopup({super.key}) : super(Routes.popupHeroEvolve);

  @override
  createState() => _HeroEvolvePopupState();
}

class _HeroEvolvePopupState extends AbstractPopupState<HeroEvolvePopup> {
  @override
  List<Widget> appBarElements() {
    return [
      Indicator(widget.name, Values.gold),
      Indicator(widget.name, Values.nectar, width: 300.d),
      Indicator(widget.name, Values.potion, width: 280.d),
    ];
  }

  @override
  String titleBuilder() => "evolve_l".l();

  @override
  Widget contentFactory() {
    return Consumer<AccountProvider>(builder: (_, state, child) {
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
      return SkinnedButton(
          width: 500.d,
          color: ButtonColor.green,
          label: titleBuilder(),
          onPressed: () => _evolve(account, hero));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SkinnedButton(
            color: ButtonColor.yellow,
            label: "+$step",
            icon: "icon_potion",
            onPressed: () => _fill(account, hero, step)),
        SizedBox(width: 10.d),
        SkinnedButton(
            color: ButtonColor.teal,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SkinnedText("fill_out".l(), style: TStyles.large),
              SizedBox(width: 16.d),
              Widgets.rect(
                padding: EdgeInsets.only(right: 12.d),
                decoration: Widgets.imageDecorator(
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
      serviceLocator<RouteService>().to(Routes.popupPotion);
    } else {
      hero.fillPotion(context, step);
    }
  }

  _evolve(Account account, HeroCard hero) async {
    Overlays.insert(
      context,
      UpgradeCardFeastOverlay(
        args: {"card": hero.card, "isHero": true},
      ),
    );
    if (mounted) {
      serviceLocator<RouteService>().popUntil((route) => route.isFirst);
    }
  }
}
