import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  List<int> _avatars = [];
  bool _avatarSelected = false;

  @override
  void initState() {
    super.initState();
    startSFX = "prize";
    _item = widget.args["item"] ??
        accountProvider
            .account.loadingData.shopProceedItems![ShopSections.gold]![1];
    _avatars = widget.args["avatars"] ?? [];
    var title = _item.base.id < 22 ? "shop_boost_xp" : "shop_boost_power";
    children = [
      backgroundBuilder(),
      animationBuilder("purchase"),
      Material(
        color: TColors.transparent,
        child: Align(
          alignment: const Alignment(0, -0.2),
          child: Stack(
            alignment: const Alignment(0, 0.37),
            children: [
              LoaderWidget(
                AssetType.image,
                title,
                subFolder: 'shop',
                height: 500.d,
                width: 500.d,
              ),
              SkinnedText(
                "${((_item.base.ratio - 1) * 100).round()}%",
                style: TStyles.large,
              ),
            ],
          ),
        ),
      ),
    ];

    process(() async {
      // if (!_item.inStore) {
      //   if (_item.base.section == ShopSections.boost) {
      //     var res = await accountProvider.boostPack(
      //         context, widget.args["item"].base);
      //     return res;
      //   } else {
      //     await accountProvider.openPack(context, widget.args["item"].base);
      //   }
      // } else {
      //   await Future.delayed(const Duration(milliseconds: 500));
      // }
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    });
  }

    @override
  void onScreenTouched() {
    if (state == RewardAnimationState.shown &&
        !_avatarSelected &&
        _item.base.reward.isNotEmpty) {
      return;
    }
    super.onScreenTouched();
  }

  @override
  void onScreenTouched() {
    if (state == RewardAnimationState.shown &&
        !_avatarSelected &&
        _item.base.reward.isNotEmpty) {
      return;
    }
    super.onScreenTouched();
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    controller.findInput<bool>("hasReward")?.value =
        _item.base.reward.isNotEmpty;
    updateRiveText("headerText", "success_l".l());
    if (_item.base.section == ShopSections.boost) {
      var title = _item.base.id < 22 ? "shop_boost_xp" : "shop_boost_power";
      updateRiveText("valueText", "${title}_desc".l([ShopData.boostDeadline.toRemainingTime()]));
    } else {
      updateRiveText("valueText", "+${_item.base.value.compact()}");
    }
    return controller;
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name.startsWith("reward") && _item.base.reward.isNotEmpty) {
        var index = int.parse(asset.name.replaceAll("reward", ""));
        _loadRewardIcon(asset, "avatar_${_avatars[index]}");
        return true;
      } else if (asset.name == "item") {
        _loadItemIcon(asset);
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }

  @override
  onRiveEvent(RiveEvent event) {
    if (event.name.startsWith("choose")) {
      int index = int.parse(event.name.replaceAll("choose_", ""));
      selectAvatar(index);
    }
    super.onRiveEvent(event);
  }

  selectAvatar(int index) async {
    process(() async {
      await serviceLocator<HttpConnection>().tryRpc(
          context, RpcId.setProfileInfo,
          params: {"avatar_id": _avatars[index]});
      accountProvider.account.avatarId = _avatars[index];
      accountProvider.update();
      _avatarSelected = true;
      return true;
    });
  }

  Future<void> _loadRewardIcon(ImageAsset asset, String name) async =>
      asset.image = await loadImage(name, subFolder: "avatars");

  Future<void> _loadItemIcon(ImageAsset asset) async {
    if (_item.base.section == ShopSections.boost) {
      // var title = _item.base.id < 22 ? "shop_boost_xp" : "shop_boost_power";
      // asset.image = await loadImage(title, subFolder: "shop");
      return;
    }
    asset.image = await loadImage(_item.getTitle(), subFolder: "shop");
  }
}
