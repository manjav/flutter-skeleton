import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class GiftRewardFeastOverlay extends AbstractOverlay {
  const GiftRewardFeastOverlay({
    super.onClose,
    super.key,
  }) : super(route: OverlaysName.feastGiftReward);

  @override
  createState() => _GiftRewardFeastOverlayState();
}

class _GiftRewardFeastOverlayState
    extends AbstractOverlayState<GiftRewardFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  late ShopItemVM _item;
  late int addedGold;
  late bool hasOffer;

  @override
  void initState() {
    super.initState();
    startSFX = "prize";
    children = [backgroundBuilder(), animationBuilder("purchase")];

    process(() async {
      var params = {
        "check":
            md5.convert(utf8.encode("${accountProvider.account.q}")).toString()
      };

      var res = await rpc(RpcId.claimAdvertismentReward, params: params);
      addedGold = res["added_gold"];
      hasOffer = res["has_special_offer"];
      if (mounted) {
        accountProvider.update(context, res);
      }
      return true;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    controller.findInput<bool>("hasReward")?.value = false;
    updateRiveText("headerText", "success_l".l());
    return controller;
  }

  @override
  void onRiveEvent(RiveEvent event) {
    super.onRiveEvent(event);
    if (state == RewardAnimationState.started) {
      updateRiveText("valueText", "+${addedGold.compact()}");
      updateRiveText("commentText",
          "You've received ${addedGold.compact()} gold. ${hasOffer ? "You receive a limited-time shop discount. Hurry before it ends!" : ""}");
    }
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
