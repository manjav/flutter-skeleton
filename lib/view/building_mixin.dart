import 'package:flutter/material.dart';

import '../../services/deviceinfo.dart';
import '../data/core/building.dart';
import '../services/localization.dart';
import '../services/theme.dart';
import 'map_elements/building_widget.dart';
import 'popups/ipopup.dart';
import 'widgets/skinnedtext.dart';

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
    return SizedBox(
        width: 360.d,
        child: BuildingWidget(building.type,
            level: building.get<int>(BuildingField.level)));
  }

  Widget dualColorText(String whiteText, String coloredText,
      {TextStyle? style}) {
    style = style ?? TStyles.large;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SkinnedText(whiteText, style: style),
      SizedBox(width: 18.d),
      SkinnedText(coloredText, style: style.copyWith(color: TColors.orange))
    ]);
  }
}
