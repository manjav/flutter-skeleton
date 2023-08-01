import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/blocs/account_bloc.dart';
import 'package:flutter_skeleton/data/core/account.dart';
import 'package:flutter_skeleton/data/core/card.dart';
import 'package:flutter_skeleton/services/deviceinfo.dart';
import 'package:flutter_skeleton/services/localization.dart';
import 'package:flutter_skeleton/services/theme.dart';
import 'package:flutter_skeleton/view/widgets/skinnedtext.dart';

import '../../utils/assets.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/loaderwidget.dart';

class HeroPopup extends AbstractPopup {
  const HeroPopup({super.key, required super.args}) : super(Routes.popupHero);

  @override
  createState() => _HeroPopupState();
}

class _HeroPopupState extends AbstractPopupState<HeroPopup> {
  int _selectedIndex = 0;

  late Account _account;
  late List<AccountCard> _cards;
  late List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _account = BlocProvider.of<AccountBloc>(context).account!;
    _cards = _account.getCards().values.where((card) => card.isHero).toList();
    _keys = List.generate(_cards.length, (index) => GlobalKey());
  }

  @override
  contentFactory() {
    var card = _cards[_selectedIndex];
    var name = card.base
        .get<FruitData>(CardFields.fruit)
        .get<String>(FriutFields.name);
    return SizedBox(
      width: 920.d,
      height: DeviceInfo.size.height * 0.6,
      child: Column(children: [
        SkinnedText("${name}_t".l()),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Widgets.button(
                padding: EdgeInsets.all(22.d),
                width: 120.d,
                height: 120.d,
                onPressed: () => _setIndex(-1),
                child: Asset.load<Image>('arrow_left')),
            Stack(alignment: Alignment.center, children: [
              Asset.load<Image>("card_frame_hero_edit", width: 420.d),
              LoaderWidget(AssetType.image, name,
                  subFolder: "cards", width: 320.d, key: _keys[_selectedIndex]),
            ]),
            Widgets.button(
                padding: EdgeInsets.all(22.d),
                width: 120.d,
                height: 120.d,
                onPressed: () => _setIndex(1),
                child: Asset.load<Image>('arrow_right')),
          ],
        ),
        SizedBox(height: 32.d),
        Widgets.rect(
            radius: 32.d,
            color: TColors.primary90,
            padding: EdgeInsets.all(16.d),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              // Asset.load<Image>("icon_gold", wi5dth: 72.d),
              // SizedBox(width: 12.d),
              // SkinnedText("combo_$index".l()),
            ])),
      ]),
    );
  }

  _setIndex(int offset) {
    _selectedIndex = (_selectedIndex + offset) % _cards.length;
    setState(() {});
  }
}
