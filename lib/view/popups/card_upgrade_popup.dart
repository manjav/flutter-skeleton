import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                  SkinnedText("${hero.potion.round()}/${capacity.round()}")
                ]),
                width: 700.d,
              ),
              SizedBox(height: 50.d),
          ));
    });
  }

  }
}
