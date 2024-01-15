import 'package:flutter/material.dart';

import '../app_export.dart';

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
                ]),
            onPressed: () => Overlays.insert(context, OverlayType.feastUpgrade,
                args: {"id": building.type.id}),
            onDisablePressed: () => Overlays.insert(context, OverlayType.toast,
                args: "max_level".l(["building_${building.type.name}_t".l()])),
          )
        ]);
  }
}
