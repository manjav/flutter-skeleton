import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import '../../blocs/account_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/card.dart';
import '../../services/deviceinfo.dart';
import '../../services/localization.dart';
import '../../services/theme.dart';
import '../../utils/assets.dart';
import '../../view/key_provider.dart';
import '../../view/popups/ipopup.dart';
import '../../view/widgets/skinnedtext.dart';
import '../route_provider.dart';
import '../widgets.dart';
import '../widgets/indicator.dart';
import '../widgets/loaderwidget.dart';

class ComboPopup extends AbstractPopup {
  const ComboPopup({super.key, required super.args}) : super(Routes.popupCombo);

  @override
  createState() => _ComboPopupState();
}

class _ComboPopupState extends AbstractPopupState<ComboPopup> with KeyProvider {
  late Account _account;
  final ValueNotifier<int> _selectedIndex = ValueNotifier(1);

  @override
  void initState() {
    contentPadding = EdgeInsets.fromLTRB(48.d, 176.d, 48.d, 72.d);
    super.initState();
    _account = BlocProvider.of<AccountBloc>(context).account!;
  }

  @override
  List<Widget> appBarElements() {
    return [
      Indicator(widget.type.name, AccountField.potion_number, width: 290.d),
      Indicator(widget.type.name, AccountField.gold),
    ];
  }

  @override
  contentFactory() {
    var style = TStyles.medium.copyWith(fontSize: 36.d);
    var style2 = TStyles.medium.copyWith(fontSize: 36.d, color: TColors.orange);
    var comboCount = _account.loadingData.comboHints.length;
    return SizedBox(
      width: 920.d,
      height: 1300.d,
      child: ValueListenableBuilder(
          valueListenable: _selectedIndex,
          builder: (context, value, child) {
            var combo = _account.loadingData.comboHints[value];
            var items = <Widget>[
              LoaderWidget(AssetType.animation, "combo",
                  key: getGlobalKey(value),
                  height: 440.d, onRiveInit: (Artboard artboard) {
                final controller =
                    StateMachineController.fromArtboard(artboard, 'Combo')!;
                var index =
                    (combo.isAvailable ? value : -combo.count).toDouble();
                controller.findInput<double>('combo')?.value = index;
                artboard.addController(controller);
              })
            ];
            items.addAll(_revealedItemsBuilder(combo, style, style2));
            items.add(const Expanded(child: SizedBox()));
            items.add(Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 16.d,
                spacing: 16.d,
                children: [
                  for (var i = 1; i < comboCount; i++) _comboItem(i)
                ]));
            return Column(children: items);
          }),
    );
  }

  List<Widget> _revealedItemsBuilder(
      ComboHint combo, TextStyle style, TextStyle style2) {
    if (!combo.isAvailable) {
      return <Widget>[
        SizedBox(height: 124.d),
        Text("combo_unavailable_description".l())
      ];
    }
    return [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Asset.load<Image>("icon_potion_number", height: 110.d),
        SkinnedText(" x${combo.cost}")
      ]),
      SizedBox(height: 24.d),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SkinnedText("combo_suit_level".l(), style: style),
        SkinnedText("combo_suit_${combo.level}".l(), style: style2),
        SizedBox(width: 32.d),
        SkinnedText("combo_suit_power".l(), style: style),
        SkinnedText("combo_suit_${combo.power}".l(), style: style2),
        SizedBox(width: 32.d),
        SkinnedText("combo_suit_fruit".l(), style: style),
        SkinnedText("combo_suit_${combo.fruit}".l(), style: style2),
      ]),
      SizedBox(height: 24.d),
      Text("combo_${combo.id}_description".l(),
          style: TStyles.medium.copyWith(height: 1)),
    ];
  }

  _comboItem(int index) {
    var selected = _selectedIndex.value == index;
    var combo = _account.loadingData.comboHints[index];
    return Widgets.button(
        height: 110.d,
        radius: 32.d,
        color: selected ? TColors.primary80 : TColors.primary90,
        padding: EdgeInsets.all(16.d),
        foregroundDecoration: selected
            ? BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(32.d)),
                border: Border.all(color: TColors.primary10, width: 8.d))
            : null,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Opacity(
              opacity: combo.isAvailable ? 1 : 0.4,
              child: Asset.load<Image>("combo_${combo.count}", width: 72.d)),
          SizedBox(width: 12.d),
          SkinnedText("combo_$index".l()),
        ]),
        onPressed: () => _selectedIndex.value = index);
  }

// local function findAvailableCombo(rowIndexOfComboTable)

//     local comboId = getsIdOfCombo(rowIndexOfComboTable)
//     local comboSettings
//     --If combo isn’t discovered
//     if comboId == 0 then
//         comboSettings = {
//             count = ComboData[rowIndexOfComboTable].count,
//             description = ComboDataLang["Combo"..ComboData[rowIndexOfComboTable].id.." unlock description"],
//             discovered = false
//         }

//         return comboSettings

//     else --If combo is discovered

//         ComboData[comboId].text = ComboDataLang["Combo"..ComboData[comboId].id]
//         ComboData[comboId].description = ComboDataLang["Combo"..ComboData[comboId].id.." description"]
//         ComboData[comboId].discovered = true

//         return ComboData[comboId]
//     end

// end

// --Boost
// BOOST_MULTIPLIERS = {
//     ["18"] = 1.5,
//     ["19"] = 2,
//     ["20"] = 3,
//     ["21"] = 5,
//     ["22"] = 1.05,
//     ["23"] = 1.1,
//     ["24"] = 1.2,
// }
}
