import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'analytics_service.dart';
import 'core/iservices.dart';
import 'sounds_service.dart';

abstract class IAdsService implements IService {
  isReady();
  showInterstitial(AdId id, String island);
  showRewarded(String source);
}

class AdsService implements IAdsService {
  final _ads = [
    MyAd(AdSDK.google, AdType.banner),
    MyAd(AdSDK.google, AdType.interstitial),
    MyAd(AdSDK.google, AdType.interstitialVideo),
    MyAd(AdSDK.google, AdType.rewarded),
    MyAd(AdSDK.unity, AdType.banner),
    MyAd(AdSDK.unity, AdType.interstitial),
    MyAd(AdSDK.unity, AdType.interstitialVideo),
    MyAd(AdSDK.unity, AdType.rewarded)
  ];
  final _myAds = <AdId, MyAd>{};

  Function(AdType, AdState, MyAd?)? onUpdate;
  static const prefix = "ca-app-pub-5018637481206902/";
  static String platform = Platform.isAndroid ? "Android" : "iOS";
  final rewardCoef = 10;
  final costCoef = 10;
  final maxFailedLoadAttempts = 3;
  final AdSDK _initialSDK = AdSDK.google;
  final Duration _waitingDuration = const Duration(milliseconds: 200);
  final AdRequest _request = const AdRequest(nonPersonalizedAds: false);
  AdSDK? selectedSDK;
  bool showSuicideInterstitial = true;
  final AnalyticsService analytics;
  final SoundService sound;

  AdsService({required this.analytics, required this.sound});

  @override
  initialize({List<Object>? args}) {
    AdSDK? sdk;
    if (args != null && args.isNotEmpty) {
      sdk = args[0] as AdSDK;
    }
    for (var v in _ads) {
      _myAds[v.id] = v;
    }
    selectedSDK = sdk ?? _initialSDK;
    if (selectedSDK == AdSDK.google) {
      MobileAds.instance.initialize();
      // _getInterstitial(AdId.interstitialGoogle);
      // _getInterstitial(AdId.interstitialVideoGoogle);
      _getRewarded(AdId.rewardedGoogle);
    } else if (selectedSDK == AdSDK.unity) {
      UnityAds.init(
        testMode: false,
        // TODO:
        gameId: "ua_${platform.toLowerCase()}",
        onComplete: () {
          _getInterstitial(AdId.interstitialUnity);
          _getInterstitial(AdId.interstitialVideoUnity);
          _getRewarded(AdId.rewardedUnity);
        },
        onFailed: (error, message) =>
            debugPrint('UnityAds Initialization Failed: $error $message'),
      );
    }
  }

  BannerAd _getGoogleBanner(String type, String island, {AdSize? size}) {
    var id = AdId.bannerGoogle;
    var myAd = _myAds[id]!;
    var listener = BannerAdListener(
        onAdLoaded: (ad) => _updateState(myAd, AdState.loaded),
        onAdFailedToLoad: (ad, error) {
          _updateState(myAd, AdState.failedLoad, error.toString());
          ad.dispose();
        },
        onAdOpened: (ad) {
          //NOTE replaces with the analytycs abstract class
          // Analytics.funnle("adbannerclick", island);
          analytics.funnle("adbannerclick", island);

          _updateState(myAd, AdState.clicked);
        },
        onAdClosed: (ad) => _updateState(myAd, AdState.closed),
        onAdImpression: (ad) => _updateState(myAd, AdState.show));
    _updateState(myAd, AdState.request);
    var ad = BannerAd(
        size: size ?? AdSize.largeBanner,
        adUnitId: id.value,
        listener: listener,
        request: _request)
      ..load();
    myAd.data = ad;
    return ad;
  }

  Widget getBannerWidget(String type, String island, {AdSize? size}) {
    var width = 320.0;
    var height = 50.0;
    Widget? adWidget;
    if (selectedSDK == AdSDK.unity) {
      var unityBanner = UnityBannerAd(placementId: AdId.bannerUnity.value);
      width = unityBanner.size.width.toDouble();
      height = unityBanner.size.height.toDouble();
      adWidget = unityBanner;
    } else {
      var banner = _getGoogleBanner(type, island, size: size);
      width = banner.size.width.toDouble();
      height = banner.size.height.toDouble();
      adWidget = AdWidget(ad: banner);
    }

    return SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: adWidget));
  }

  void _getInterstitial(AdId id) {
    var myAd = _myAds[id]!;
    if (myAd.sdk == AdSDK.unity) {
      _getUnityAd(id);
      return;
    }

    InterstitialAd.load(
        adUnitId: id.value,
        request: _request,
        adLoadCallback:
            InterstitialAdLoadCallback(onAdLoaded: (InterstitialAd ad) {
          _updateState(myAd, AdState.loaded);
          myAd.data = ad;
          ad.setImmersiveMode(true);
        }, onAdFailedToLoad: (LoadAdError error) async {
          _updateState(myAd, AdState.failedLoad, error.toString());
          myAd.data = null;
          myAd.attempts++;
          await Future.delayed(_waitingDuration);
          if (myAd.attempts <= maxFailedLoadAttempts) {
            _getInterstitial(id);
          }
        }));
  }

  void _getRewarded(AdId id) {
    var myAd = _myAds[id]!;

    if (myAd.sdk == AdSDK.unity) {
      _getUnityAd(id);
      return;
    }

    RewardedAd.load(
        adUnitId: id.value,
        request: _request,
        rewardedAdLoadCallback:
            RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
          myAd.data = ad;
          _updateState(myAd, AdState.loaded);
        }, onAdFailedToLoad: (LoadAdError error) async {
          _updateState(myAd, AdState.failedLoad, error.toString());
          myAd.data = null;
          myAd.attempts++;
          await Future.delayed(_waitingDuration);
          if (myAd.attempts <= maxFailedLoadAttempts) {
            _getRewarded(id);
          } else if (_initialSDK == AdSDK.google) {
            initialize(args: [AdSDK.unity]); // Alternative AD SDK
          }
        }));
  }

  @override
  AdId isReady([AdType? type, bool? gapConsidering, AdSDK? sdk]) {
    type = type ?? AdType.rewarded;
    sdk = sdk ?? AdSDK.google;
    var id = type.getId(sdk);
    var myAd = _myAds[id]!;
    if (myAd.data != null && myAd.state == AdState.loaded) {
      return id;
    }

    if (sdk == AdSDK.google) {
      return isReady(type, gapConsidering, AdSDK.unity);
    }
    return AdId.none;
  }

  @override
  showInterstitial(AdId id, String island) async {
    if (id == AdId.none) return; // Ad is not available.
    var myAd = _myAds[id]!;

    if (myAd.sdk == AdSDK.unity) {
      return await _showUnityAd(id);
    }

    var iAd = myAd.data as InterstitialAd;
    iAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) =>
            _updateState(myAd, AdState.closed),
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) =>
            _updateState(myAd, AdState.failedShow, error.toString()),
        onAdImpression: (ad) => _updateState(myAd, AdState.show));
    iAd.show();
    await _waitForClose(id);
    _resetAd(myAd);
    // NOTE: used abstracty Analytics class
    analytics.funnle("adinterstitial", island);
    // services.get<Analytics>().funnle("adinterstitial", island);
  }

  @override
  Future<RewardItem?> showRewarded(String source) async {
    var id = isReady(AdType.rewarded);
    if (id == AdId.none) return null; // Ad is not available.

    // NOTE: Add Service
    sound.stop("music");
    // services.get<Sounds>().stop("music");

    var myAd = _myAds[id]!;
    if (myAd.sdk == AdSDK.unity) {
      return await _showUnityAd(id);
    }

    var rAd = myAd.data as RewardedAd;
    rAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) =>
            _updateState(myAd, AdState.closed),
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) =>
            _updateState(myAd, AdState.failedShow, error.toString()),
        onAdImpression: (ad) => _updateState(myAd, AdState.show));
    rAd.setImmersiveMode(true);
    rAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      myAd.reward = rewardItem;
    });
    await _waitForClose(id);
    if (myAd.reward != null) {
      // NOTE: replaced

      // analytics.funnle("adrewarded", island);
      // services.get<Analytics>().funnle("adrewarded", island);
    }
    _resetAd(myAd);
    // NOTE: Add Service

    // services.get<Sounds>().play("african-fun", channel: "music");
    sound.play("african-fun", channel: "music");
    return myAd.reward;
  }

  void _getUnityAd(AdId id) {
    var myAd = _myAds[id]!;
    UnityAds.load(
        placementId: id.value,
        onComplete: (placementId) {
          myAd.data = {};
          _updateState(myAd, AdState.loaded);
        },
        onFailed: (placementId, error, message) {
          _updateState(myAd, AdState.failedLoad, error.toString());
        });
  }

  Future<RewardItem?> _showUnityAd(AdId id) async {
    var myAd = _myAds[id]!;
    UnityAds.showVideoAd(
      placementId: id.value,
      onStart: (placement) => _updateState(myAd, AdState.show),
      onClick: (placement) => _updateState(myAd, AdState.clicked),
      onSkipped: (placement) => _updateState(myAd, AdState.closed),
      onComplete: (iD) {
        myAd.reward = RewardItem(1, id.value);
        _updateState(myAd, AdState.closed);
      },
      onFailed: (id, e, messaeg) =>
          _updateState(myAd, AdState.failedShow, messaeg),
    );

    myAd.state = AdState.show;
    await _waitForClose(id);
    _resetAd(myAd);
    return myAd.reward;
  }

  void _updateState(MyAd myAd, AdState state, [String? error]) {
    if (myAd.state == state) return;
    myAd.state = state;
    onUpdate?.call(myAd.type, myAd.state, myAd);
    if (myAd.order > 0) {
      // Analytics.ad(myAd.order, myAd.type.code, myAd.id.value, myAd.sdk.name);
    }
    debugPrint("Ads ==> ${myAd.sdk} ${myAd.id} $state ${error ?? ''}");
  }

  _waitForClose(AdId id) async {
    var myAd = _myAds[id]!;
    while (myAd.state == AdState.loaded || myAd.state == AdState.show) {
      debugPrint("Ads ==> _waitForClose ${myAd.state} ${myAd.id}");
      await Future.delayed(_waitingDuration);
    }
  }

  _resetAd(MyAd myAd) async {
    if (myAd.sdk == AdSDK.google) {
      myAd.data!.dispose();
    }
    myAd.data = null;
    await Future.delayed(_waitingDuration);
    if (myAd.type == AdType.rewarded) {
      _getRewarded(myAd.id);
    } else {
      _getInterstitial(myAd.id);
    }
  }

  void resumeApp() {
    _myAds.forEach((key, value) {
      if (value.type != AdType.banner && value.state == AdState.show) {}
    });
  }

  @override
  log(log) {
    debugPrint(log);
    sound.log(
        "*-sound inside ads log"); //TODO-hamiiid: to test using another service methods inside this one.
  }
}

class MyAd {
  final gapThreshold = 35000;
  final AdSDK sdk;
  final AdType type;
  AdId get id => type.getId(sdk);

  int attempts = 0;
  dynamic data;
  AdState state = AdState.closed;
  RewardItem? _reward;

  MyAd(this.sdk, this.type);

  int get order {
    if (state == AdState.failedLoad) return -1;
    return state.index;
  }

  RewardItem? get reward => _reward;
  set reward(RewardItem? value) {
    _reward = value;
    if (_reward != null) {
      // Analytics.ad(4, type.code, id.value, sdk.name);
    }
  }
}

enum AdSDK { none, google, unity }

extension AdSDKExt on AdSDK {
  String get name {
    switch (this) {
      case AdSDK.none:
        return "none";
      case AdSDK.google:
        return "google";
      case AdSDK.unity:
        return "unity";
    }
  }
}

enum AdState {
  closed,
  clicked, //Clicked = 1;
  show, // Show = 2;
  failedShow, //FailedShow = 3;
  request, //Request = 5;
  loaded, //Loaded = 6;
  failedLoad,
}

enum AdType {
  banner,
  interstitial,
  interstitialVideo,
  rewarded,
}

enum AdId {
  bannerGoogle,
  bannerUnity,
  interstitialGoogle,
  interstitialUnity,
  interstitialVideoGoogle,
  interstitialVideoUnity,
  rewardedGoogle,
  rewardedUnity,
  none
}

extension AdTypeExt on AdType {
  /* get code {
    switch (this) {
      case AdType.banner:
        return GAAdType.Banner;
      case AdType.interstitial:
        return GAAdType.OfferWall;
      case AdType.interstitialVideo:
        return GAAdType.Interstitial;
      case AdType.rewarded:
        return GAAdType.RewardedVideo;
    }
  } */

  AdId getId(AdSDK sdk) {
    if (sdk == AdSDK.google) {
      switch (this) {
        case AdType.banner:
          return AdId.bannerGoogle;
        case AdType.interstitial:
          return AdId.interstitialGoogle;
        case AdType.interstitialVideo:
          return AdId.interstitialVideoGoogle;
        case AdType.rewarded:
          return AdId.rewardedGoogle;
      }
    }
    switch (this) {
      case AdType.banner:
        return AdId.bannerUnity;
      case AdType.interstitial:
        return AdId.interstitialUnity;
      case AdType.interstitialVideo:
        return AdId.interstitialVideoUnity;
      case AdType.rewarded:
        return AdId.rewardedUnity;
    }
  }

  bool isIntrestitial() {
    return this == AdType.interstitial || this == AdType.interstitialVideo;
  }
}

extension AdPlaceExt on AdId {
  String get value {
    switch (this) {
      case AdId.bannerGoogle:
        return "${AdsService.prefix}4165381925";
      case AdId.bannerUnity:
        return "Banner_${AdsService.platform}";
      case AdId.interstitialGoogle:
        return "${AdsService.prefix}7354823488";
      case AdId.interstitialUnity:
        return "Interstitial_${AdsService.platform}";
      case AdId.interstitialVideoGoogle:
        return "${AdsService.prefix}7354823488";
      case AdId.interstitialVideoUnity:
        return "Interstitial_${AdsService.platform}";
      case AdId.rewardedGoogle:
        return "${AdsService.prefix}6943759940";
      case AdId.rewardedUnity:
        return "Rewarded_${AdsService.platform}";
      case AdId.none:
        return "none";
    }
  }
}
