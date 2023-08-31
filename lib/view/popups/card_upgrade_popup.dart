import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/core/account.dart';
import '../../data/core/card.dart';
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
                  SkinnedText("${hero.potion.round()}/${capacity.round()}")
                ]),
                width: 700.d,
              ),
              SizedBox(height: 50.d),
          ));
    });
  }

  _buttons(Account account, HeroCard hero, int capacity) {
    var bgCenterSlice = ImageCenterSliceDate(42, 42);
    int price = ((capacity - hero.potion) * HeroCard.evolveBaseNectar).round();
    var step = 50;

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
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.fill,
                        centerSlice: bgCenterSlice.centerSlice,
                        image: Asset.load<Image>('ui_frame_inside',
                                centerSlice: bgCenterSlice)
                            .image)),
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
}
