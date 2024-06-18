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
  List<int> _avatars = [];
  bool _avatarSelected = false;

  @override
  void initState() {
    super.initState();
    startSFX = "prize";
    children = [backgroundBuilder(), animationBuilder("purchase")];
    _item = widget.args["item"] ??
        accountProvider
            .account.loadingData.shopProceedItems![ShopSections.gold]![1];
    _avatars = widget.args["avatars"] ?? [];

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
      if (asset.name.startsWith("reward")) {
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

  Future<void> _loadItemIcon(ImageAsset asset) async =>
      asset.image = await loadImage(_item.getTitle(), subFolder: "shop");
}
