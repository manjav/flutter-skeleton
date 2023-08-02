import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/deviceinfo.dart';
import 'package:flutter_skeleton/services/localization.dart';
import 'package:flutter_skeleton/services/theme.dart';
import 'package:flutter_skeleton/view/widgets/skinnedtext.dart';

import '../../utils/assets.dart';
import '../../view/popups/ipopup.dart';
import '../route_provider.dart';
import '../widgets.dart';

class ComboPopup extends AbstractPopup {
  const ComboPopup({super.key, required super.args}) : super(Routes.popupCombo);

  @override
  createState() => _ComboPopupState();
}

class _ComboPopupState extends AbstractPopupState<ComboPopup> {
  int _selectedCombo = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  List<Widget> appBarElements() {
    return [
      Indicator(widget.type.name, AccountField.potion_number,
          hasPlusIcon: true, width: 290.d),
      Indicator(widget.type.name, AccountField.gold, hasPlusIcon: true),
    ];
  }

  @override
  contentFactory() {
    return SizedBox(
      width: 920.d,
      height: DeviceInfo.size.height * 0.7,
      child: Column(children: [
        Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 16.d,
          spacing: 16.d,
          children: [for (var i = 0; i < 8; i++) _comboItem(i)],
        )
      ]),
    );
  }

  _comboItem(int index) {
    return Widgets.button(
        radius: 32.d,
        color: TColors.primary90,
        padding: EdgeInsets.all(16.d),
        foregroundDecoration: _selectedCombo == index
            ? BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(32.d)),
                border: Border.all(color: TColors.primary10, width: 8.d))
            : null,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Asset.load<Image>("icon_gold", width: 72.d),
          SizedBox(width: 12.d),
          SkinnedText("combo_$index".l()),
        ]),
        onPressed: () => setState(() => _selectedCombo = index));
  }
}
