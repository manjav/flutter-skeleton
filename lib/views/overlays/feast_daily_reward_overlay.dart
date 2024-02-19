import 'dart:async';
import 'dart:typed_data';

import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class DailyRewardFeastOverlay extends AbstractOverlay {
  const DailyRewardFeastOverlay({super.onClose, super.key})
      : super(route: OverlaysName.feastDailyReward);

  @override
  createState() => _DailyRewardFeastOverlayState();
}

class _DailyRewardFeastOverlayState
    extends AbstractOverlayState<DailyRewardFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  int _baseReward = 0;

  @override
  void initState() {
    super.initState();
    startSFX = "prize";
    children = [backgroundBuilder(), animationBuilder("purchase")];
    var account = accountProvider.account;
    _baseReward = account.dailyReward["base_gold"] ?? 1000;

    process(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    controller.findInput<bool>("hasReward")?.value = false;
    updateRiveText("headerText", "daily_gifts".l());
    updateRiveText("valueText", "+${_baseReward.compact()}");
    return controller;
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "item") {
        _loadItemIcon(asset);
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }
  
  Future<void> _loadItemIcon(ImageAsset asset) async =>
      asset.image = await loadImage("daily_reward", subFolder: "shop");
}
