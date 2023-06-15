import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../../services/localization.dart';
import 'ads_abstract.dart';

class AdUnity extends AbstractAdSDK {
  static String platform = Platform.isAndroid ? "Android" : "iOS";

  @override
  Future<void> initialize(AdSDKName sdk, {bool testMode = false}) async {
    super.initialize(sdk, testMode: testMode);
    sdk = AdSDKName.unity;
    UnityAds.init(
      testMode: false,
      gameId: "ads_${sdk.name}_${platform.toLowerCase()}".l(),
      onComplete: () {
        request(AdType.interstitial);
        request(AdType.interstitialVideo);
        request(AdType.rewarded);
      },
      onFailed: (error, message) =>
          debugPrint('UnityAds Initialization Failed: $error $message'),
    );
  }

  @override
  Placement getBanner(String origin, {Size? size}) {
    var placement = placements[AdType.banner]!;
    placement.data = origin;
    placement.nativeAd = UnityBannerAd(placementId: placement.id);
    return placement;
  }

  @override
  void request(AdType type) {
    var placement = placements[type]!;
    UnityAds.load(
        placementId: placement.id,
        onComplete: (placementId) {
          placement.data = {};
          updateState(placement, AdState.loaded);
        },
        onFailed: (placementId, error, message) {
          updateState(placement, AdState.failedLoad, error.toString());
        });
  }

  @override
  Future<Placement?> show(AdType type, {String? origin}) async {
    var placement = isReady(type);
    if (placement == null) {
      return null;
    }
    UnityAds.showVideoAd(
      placementId: placement.id,
      onStart: (placementId) => updateState(placement, AdState.show),
      onClick: (placementId) => updateState(placement, AdState.clicked),
      onSkipped: (placementId) => updateState(placement, AdState.closed),
      onComplete: (placementId) {
        placement.reward = {"reward": true};
        updateState(placement, AdState.closed);
      },
      onFailed: (id, e, messaeg) =>
          updateState(placement, AdState.failedShow, messaeg),
    );

    placement.state = AdState.show;
    await waitForClose(type);
    resetAd(placement);
    return placement;
  }
}
