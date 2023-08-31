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
          ));
    });
  }

  }
}
