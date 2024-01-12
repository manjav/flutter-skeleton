import 'dart:async';
import 'dart:typed_data';

import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/store.dart';
import '../../mixins/background_mixin.dart';
import '../../mixins/reward_mixin.dart';
import '../../services/localization.dart';
import '../../utils/utils.dart';
import 'overlay.dart';

class PurchaseFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const PurchaseFeastOverlay({required this.args, super.onClose, super.key})
      : super(type: OverlayType.feastPurchase);

  @override
  createState() => _PurchaseFeastOverlayState();
}

class _PurchaseFeastOverlayState
    extends AbstractOverlayState<PurchaseFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  late ShopItemVM _item;

  @override
  void initState() {
    super.initState();
    startSFX = "prize";
    children = [backgroundBuilder(), animationBuilder("purchase")];
    _item = widget.args["item"] ??
        accountProvider
            .account.loadingData.shopProceedItems![ShopSections.gold]![1];

    process(() async {
      if (!_item.inStore) {
        await accountProvider.openPack(context, widget.args["item"].base);
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      return true; //await rpc(RpcId.buyGoldPack, params: params);
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    controller.findInput<bool>("hasReward")?.value =
        _item.base.reward.isNotEmpty;
    updateRiveText("headerText", "success_l".l());
    updateRiveText("valueText", "+${_item.base.value.compact()}");
    return controller;
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "reward") {
        _loadRewardIcon(asset, "avatar_109");
        return true;
      } else if (asset.name == "item") {
        _loadItemIcon(asset);
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }

  Future<void> _loadRewardIcon(ImageAsset asset, String name) async =>
      asset.image = await loadImage(name, subFolder: "avatars");

  Future<void> _loadItemIcon(ImageAsset asset) async =>
      asset.image = await loadImage(_item.getTitle(), subFolder: "shop");
}
