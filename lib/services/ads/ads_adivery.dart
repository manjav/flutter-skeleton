import 'dart:io';

import 'package:adivery/adivery.dart';
import 'package:adivery/adivery_ads.dart';
import 'package:flutter/material.dart';

import '../../skeleton/services/ads/ads_abstract.dart';
import '../../skeleton/services/localization.dart';

class AdAdivery extends AbstractAdSDK {
  static String platform = Platform.isAndroid ? "Android" : "iOS";

  @override
  void initialize(AdSDKName sdk, {bool testMode = false}) {
    super.initialize(sdk, testMode: testMode);

    AdiveryPlugin.initialize("ads_${sdk.name}_${platform.toLowerCase()}".l());
    AdiveryPlugin.setLoggingEnabled(testMode);
    AdiveryPlugin.addListener(
        onError: (placementId, error) =>
            updateState(findPlacement(placementId), AdState.failedLoad, error),
        onInterstitialLoaded: (placementId) =>
            updateState(findPlacement(placementId), AdState.loaded),
        onRewardedLoaded: (placementId) => {},
        onRewardedClosed: (placementId, isRewarded) {
          var placement = findPlacement(placementId);
          if (isRewarded) {
            placement.reward = {"reward": true};
          }
          updateState(placement, AdState.closed);
        });

    request(AdType.interstitial);
    request(AdType.native);
    request(AdType.rewarded);
  }

  @override
  Placement getBanner(String origin, {Size? size}) {
    var placement = placements[AdType.banner]!;
    var banner = BannerAd(
      placement.id,
      size == null ? BannerAdSize.LARGE_BANNER : BannerAdSize.BANNER,
      onAdLoaded: (ad) {
        placement.nativeAd = ad;
        updateState(placement, AdState.loaded);
      },
      onAdClicked: (ad) => updateState(placement, AdState.clicked),
      onError: (ad, reason) =>
          updateState(placement, AdState.failedLoad, reason),
    );
    placement.data = origin;
    placement.nativeAd = banner;
    return placement;
  }

  @override
  void request(AdType type) {
    if (type.isInterstitial) {
      AdiveryPlugin.prepareInterstitialAd(placements[type]!.id);
    } else {
      AdiveryPlugin.prepareRewardedAd(placements[type]!.id);
    }
  }

  @override
  Future<Placement?> show(AdType type, {String? origin}) async {
    var placement = isReady(type);
    if (placement == null) {
      return null;
    }
    AdiveryPlugin.show(placement.id);
    placement.state = AdState.show;
    await waitForClose(type);
    resetAd(placement);
    return placement;
  }
}
