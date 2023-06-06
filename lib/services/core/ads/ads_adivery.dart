import 'dart:io';

import 'package:adivery/adivery.dart';
import 'package:adivery/adivery_ads.dart';
import 'package:flutter/material.dart';

import '../../localization_service.dart';
import 'ads_abstract.dart';

class AdUnity extends AbstractAdSDK {
  static String platform = Platform.isAndroid ? "Android" : "iOS";

  @override
  void initialize({bool testMode = false}) {
    super.initialize(testMode: testMode);
    sdk = AdSDKName.adivery;


    
    AdiveryPlugin.initialize("ads_${sdk}_${platform.toLowerCase()}".l());
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
    request(AdType.interstitialVideo);
    request(AdType.rewarded);
  }

  @override
  Placement getBanner(String origin, {Size? size}) {
    var placement = placements[AdType.banner]!;
    var banner = BannerAd(
      getId(AdType.banner),
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
    if (type.isIntrestitial) {
      AdiveryPlugin.prepareInterstitialAd(getId(type));
    } else {
      AdiveryPlugin.prepareRewardedAd(getId(type));
    }
  }

  @override
  Future<Placement?> show(AdType type, {String? origin}) async {
    var placement = isReady(type);
    if (placement == null) {
      return null;
    }
    AdiveryPlugin.show(getId(type));
    placement.state = AdState.show;
    await waitForClose(type);
    resetAd(placement);
    return placement;
  }
}
