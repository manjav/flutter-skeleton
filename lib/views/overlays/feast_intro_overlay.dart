import 'dart:async';
import 'dart:typed_data';

import 'package:rive/rive.dart';
// ignore: implementation_imports
import 'package:rive/src/rive_core/assets/file_asset.dart';

import '../../app_export.dart';

class IntroFeastOverlay extends AbstractOverlay {
  const IntroFeastOverlay({super.onClose, super.key})
      : super(route: OverlaysName.feastIntro);

  @override
  createState() => _IntroScreenState();
}

class _IntroScreenState extends AbstractOverlayState<IntroFeastOverlay>
    with RewardScreenMixin, BackgroundMixin {
  @override
  void initState() {
    super.initState();
    startSFX = "";
    children = [animationBuilder("intro")];
    process(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    });
  }

  @override
  void onScreenTouched() {
    if (state.index <= RewardAnimationState.waiting.index) return;
    skipInput?.value = true;
  }

  @override
  StateMachineController onRiveInit(
      Artboard artboard, String stateMachineName) {
    var controller = super.onRiveInit(artboard, stateMachineName);
    return controller;
  }

  
  @override
  Future<bool> onRiveAssetLoad(
      FileAsset asset, Uint8List? embeddedBytes) async {
    if (asset is ImageAsset) {
      if (asset.name == "logo") {
        _loadLogoIcon(asset, "logo_${Localization.languageCode}");
        return true;
      }
    }
    return super.onRiveAssetLoad(asset, embeddedBytes);
  }

  Future<void> _loadLogoIcon(ImageAsset asset, String name) async =>
      asset.image = await loadImage(name);
}
