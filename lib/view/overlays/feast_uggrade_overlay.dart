import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../data/core/building.dart';
import '../../mixins/background_mixin.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/localization.dart';
import '../../view/map_elements/building_widget.dart';
import 'overlay.dart';

class UpgradeFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const UpgradeFeastOverlay({required this.args, super.onClose, super.key})
      : super(type: OverlayType.feastUpgrade);

  @override
  createState() => _UpgradeFeastOverlayState();
}

class _UpgradeFeastOverlayState
    extends AbstractOverlayState<UpgradeFeastOverlay>
    with RewardScreenMixin, BackgroundMixin, TickerProviderStateMixin {
  late int _buildingId;
  late Building _building;

  @override
  void initState() {
    super.initState();

    children = [backgroundBuilder(), animationBuilder("evolvehero")];
    _buildingId = widget.args["id"] ?? 1002;
    _building = accountBloc.account!.buildings[_buildingId.toBuildings()]!;
    var tribe = widget.args["tribe"] ?? accountBloc.account!.tribe;
    children = [
      backgroundBuilder(),
      animationBuilder("upgrade"),
      _buildingWidget()
    ];
    process(() async =>
        await accountBloc.upgrade(context, _building, tribe: tribe));
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    _updateTexts();
    return controller;
  }


  Widget _buildingWidget() {
    return IgnorePointer(
        child: BuildingWidget(_building));
  }

  void _updateTexts() {
    updateRiveText("headerText", "upgrade_l".l());
    // updateRiveText("upToCaptionText", "upgraded_l".l([_building.level]));
    updateRiveText("upToCaptionText", "upgrade_t_$_buildingId".l());
    var benefit = _building.benefit.convert();
    updateRiveText(
        "upToText", "$benefit${_buildingId == Buildings.tribe.id ? "ˡ" : "%"}");
  }
}
