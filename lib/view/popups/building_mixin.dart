import 'package:flutter/material.dart';

import '../../data/core/building.dart';
import '../../services/localization.dart';
import 'ipopup.dart';

@optionalTypeArgs
mixin BuildingPopupMixin<T extends AbstractPopup> on State<T> {
  late Building building;

  @override
  void initState() {
    building = widget.args['building'];
    super.initState();
  }

  titleBuilder() => "building_${building.type.name}_t".l();
  descriptionBuilder() => "building_${building.type.name}_d".l();
}
