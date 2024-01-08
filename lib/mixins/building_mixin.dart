import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/utils.dart';
import '../../view/widgets.dart';
import '../blocs/account_bloc.dart';
import '../data/core/account.dart';
import '../data/core/building.dart';
import '../services/device_info.dart';
import '../services/localization.dart';
import '../services/theme.dart';
import '../utils/assets.dart';
import '../view/map_elements/building_widget.dart';
import '../view/overlays/overlay.dart';
import '../view/popups/popup.dart';
import '../view/widgets/skinned_text.dart';

@optionalTypeArgs
mixin BuildingPopupMixin<T extends AbstractPopup> on State<T> {
  late Building building;

  @override
  void initState() {
    building = widget.args['building'];
    super.initState();
  }

  String titleBuilder() => "building_${building.type.name}_t".l();
  String descriptionBuilder() => "building_${building.type.name}_d".l();
  getBuildingIcon() {
    return SizedBox(width: 360.d, child: BuildingWidget(building));
  }

  upgradeButton(Account account, Building building) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Widgets.skinnedButton(
            context,
            height: 160.d,
            isEnable: building.level < building.maxLevel,
            color: ButtonColor.green,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 8.d),
                SkinnedText("upgrade_l".l(),
                    style: TStyles.large.copyWith(height: 3.d)),
                SizedBox(width: 24.d),
                Widgets.rect(
                  padding:
                      EdgeInsets.symmetric(vertical: 6.d, horizontal: 12.d),
                  decoration: Widgets.imageDecorator(
                      "frame_hatch_button", ImageCenterSliceData(42)),
                  child: Row(children: [
                    Asset.load<Image>("icon_gold", height: 76.d),
                    SkinnedText(building.upgradeCost.compact(),
                        style: TStyles.large),
                  ]),
                )
              ],
            ),
            onPressed: () => _upgrade(account, building),
            onDisablePressed: () => Overlays.insert(context, OverlayType.toast,
                args: "max_level".l(["building_${building.type.name}_t".l()])),
          )
        ]);
  }

  _upgrade(Account account, Building building) async {
    try {
      var result = await BlocProvider.of<AccountBloc>(context)
          .upgrade(context, building.type.id);
      building.level = result["level"];
    } finally {}
  }
}
