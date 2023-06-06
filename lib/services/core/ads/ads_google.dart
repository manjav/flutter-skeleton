import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_abstract.dart';

class AdGoogle extends AbstractAdSDK {
  final AdRequest _request = const AdRequest(nonPersonalizedAds: false);

  @override
  Future<void> initialize(AdSDKName sdk, {bool testMode = false}) async {
    super.initialize(sdk, testMode: testMode);
    await MobileAds.instance.initialize();
  }

  @override
  Placement getBanner(String? origin, {Size? size}) {
    var placement = placements[AdType.banner]!;
    placement.data = origin;
    var listener = BannerAdListener(
        onAdLoaded: (ad) => updateState(placement, AdState.loaded),
        onAdFailedToLoad: (ad, error) {
          updateState(placement, AdState.failedLoad, error.toString());
          ad.dispose();
        },
        onAdOpened: (ad) {
          updateState(placement, AdState.clicked);
        },
        onAdClosed: (ad) => updateState(placement, AdState.closed),
        onAdImpression: (ad) => updateState(placement, AdState.show));
    updateState(placement, AdState.request);
    var ad = BannerAd(
        size: size == null
            ? AdSize.largeBanner
            : AdSize(width: size.width.toInt(), height: size.height.toInt()),
        adUnitId: getId(AdType.banner),
        listener: listener,
        request: _request)
      ..load();
    placement.nativeAd = ad;
    return placement;
  }

  @override
  void request(AdType type) {
    var placement = placements[type]!;
    if (type.isIntrestitial) {
      InterstitialAd.load(
          adUnitId: getId(type),
          request: _request,
          adLoadCallback:
              InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
            placement.nativeAd = ad;
            updateState(placement, AdState.loaded);
            ad.setImmersiveMode(true);
          }, onAdFailedToLoad: (LoadAdError error) async {
            updateState(placement, AdState.failedLoad, error.toString());
            placement.nativeAd = null;
            placement.attempts++;
            await Future.delayed(waitingDuration);
            if (placement.attempts <= maxFailedLoadAttempts) {
              request(type);
              // } else if (_initialSDK == AdSDKName.google) {
              //   initialize(args: [AdSDKName.unity]); // Alternative AD SDK
            }
          }));
      return;
    }
    RewardedAd.load(
        adUnitId: getId(AdType.rewarded),
        request: _request,
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          placement.nativeAd = ad;
          updateState(placement, AdState.loaded);
        }, onAdFailedToLoad: (LoadAdError error) async {
          updateState(placement, AdState.failedLoad, error.toString());
          placement.data = null;
          placement.attempts++;
          await Future.delayed(waitingDuration);
          if (placement.attempts <= maxFailedLoadAttempts) {
            request(type);
            // } else if (_initialSDK == AdSDKName.google) {
            //   initialize(args: [AdSDKName.unity]); // Alternative AD SDK
          }
        }));
  }

  @override
  Future<Placement?> show(AdType type, {String? origin}) async {
    var placement = isReady(AdType.rewarded);
    if (placement == null) {
      return null;
    }
    if (type.isIntrestitial) {
      var nativeAd = placement.data as InterstitialAd;
      nativeAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) =>
              updateState(placement, AdState.closed),
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) =>
                  updateState(placement, AdState.failedShow, error.toString()),
          onAdImpression: (ad) => updateState(placement, AdState.show));
      nativeAd.show();
      await waitForClose(type);
      resetAd(placement);
      return placement;
    }
    // sound.stop("music");
    var nativeAd = placement.nativeAd as RewardedAd;
    nativeAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) =>
            updateState(placement, AdState.closed),
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) =>
            updateState(placement, AdState.failedShow, error.toString()),
        onAdImpression: (ad) => updateState(placement, AdState.show));
    nativeAd.setImmersiveMode(true);
    nativeAd.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      placement.reward = rewardItem;
    });
    await waitForClose(placement.type);
    resetAd(placement);
    // sound.play("african-fun", channel: "music");
    return placement;
  }
}
