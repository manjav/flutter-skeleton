import 'dart:async';
import 'dart:typed_data';

import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class PurchaseFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const PurchaseFeastOverlay({required this.args, super.onClose, super.key})
      : super(route: OverlaysName.feastPurchase);

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
        if (_item.base.section == ShopSections.boost) {
          var res = await accountProvider.boostPack(
              context, widget.args["item"].base);
          return res;
        } else {
          await accountProvider.openPack(context, widget.args["item"].base);
        }
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
