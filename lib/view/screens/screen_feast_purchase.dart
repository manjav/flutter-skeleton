import 'dart:async';
import 'dart:typed_data';

import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../data/core/store.dart';
import '../../services/localization.dart';
import '../../services/sounds.dart';
import '../../utils/utils.dart';
import '../mixins/reward_mixin.dart';
import '../route_provider.dart';
import 'iscreen.dart';

class PurchaseFeastScreen extends AbstractScreen {
  PurchaseFeastScreen({required super.args, super.key})
      : super(Routes.feastLevelup);

  @override
  createState() => _PurchaseFeastScreenState();
}

class _PurchaseFeastScreenState extends AbstractScreenState<PurchaseFeastScreen>
    with RewardScreenMixin {
  late ShopItemVM _item;

  @override
  void initState() {
    super.initState();
    getService<Sounds>().play("levelup");
    children = [backgrounBuilder(), animationBuilder("purchase")];
    _item = widget.args["item"] ??
        accountBloc
            .account!.loadingData.shopProceedItems![ShopSections.gold]![1];
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
