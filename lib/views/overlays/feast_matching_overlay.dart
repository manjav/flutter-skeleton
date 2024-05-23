import 'dart:async';
import 'dart:typed_data';

import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class MatchingFeastOverlay extends AbstractOverlay {
  final Map<String, dynamic> args;
  const MatchingFeastOverlay({required this.args, super.onClose, super.key})
      : super(route: OverlaysName.matching);

  @override
  createState() => _MatchingFeastOverlayState();
}

class _MatchingFeastOverlayState
    extends AbstractOverlayState<MatchingFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  @override
  void initState() {
    super.initState();
    startSFX = "battle";
    children = [animationBuilder("matching")];

    process(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    });
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    updateRiveText("playerNameText", accountProvider.account.name);
    updateRiveText("opponentNameText", "boss".l());
    return controller;
  }

  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "playerAvatar") {
        asset.image = await loadImage(
            "avatar_${accountProvider.account.avatarId}",
            subFolder: "avatars");
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }
}
