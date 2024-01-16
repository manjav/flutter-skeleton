import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../app_export.dart';

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
  late AnimationController _animationController;
  get _postFix {
    return switch (_building.type) {
      Buildings.tribe => "ˡ",
      Buildings.mine || Buildings.treasury => "",
      _ => "%"
    };
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, upperBound: 2);
    _buildingId = widget.args["id"] ?? 1002;
    _building = accountProvider.account.buildings[_buildingId.toBuildings()]!;
    var tribe = widget.args["tribe"] ?? accountProvider.account.tribe;
    children = [
      backgroundBuilder(),
      animationBuilder("upgrade"),
      _buildingWidget()
    ];
    process(() async =>
        await accountProvider.upgrade(context, _building, tribe: tribe));
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    _updateTexts();
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAnimationState.started) {
      _updateTexts();
      _animationController.animateTo(2,
          curve: Curves.easeOutBack, duration: const Duration(seconds: 1));
    } else if (state == RewardAnimationState.closing) {
      _animationController.animateTo(0,
          curve: Curves.easeInBack,
          duration: const Duration(milliseconds: 300));
    }
  }

  Widget _buildingWidget() {
    return IgnorePointer(
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Transform.scale(
                scale: _animationController.value,
                child: BuildingWidget(_building))));
  }

  void _updateTexts() {
    updateRiveText("headerText", "upgrade_l".l());
    // updateRiveText("upToCaptionText", "upgraded_l".l([_building.level]));
    updateRiveText("upToCaptionText", "upgrade_t_$_buildingId".l());
    var benefit = _building.benefit.compact();
    updateRiveText("upToText", "$benefit$_postFix");
  }

  @override
  void dismiss() {
    super.dismiss();
    _animationController.dispose();
  }
}