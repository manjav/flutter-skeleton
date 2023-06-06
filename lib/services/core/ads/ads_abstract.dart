import 'package:flutter/material.dart';
import '../../localization_service.dart';

enum AdSDKName { none, adivery, google, unity }

extension AdSDKExt on AdSDKName {
  String get name {
    switch (this) {
      case AdSDKName.none:
        return "none";
      case AdSDKName.adivery:
        return "adivery";
      case AdSDKName.google:
        return "google";
      case AdSDKName.unity:
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

extension AdTypeExtension on AdType {
  bool get isIntrestitial =>
      this == AdType.interstitial || this == AdType.interstitialVideo;
}

class Placement {
  final gapThreshold = 35000;
  final AdSDKName sdk;
  final AdType type;
  late final String id;
  int attempts = 0;
  dynamic data;
  dynamic reward;
  dynamic nativeAd;
  AdState state = AdState.closed;

  Placement(this.sdk, this.type) {
    id = "adid_${sdk}_$type".l();
  }
  int get order {
    if (state == AdState.failedLoad) return -1;
    return state.index;
  }
}

abstract class AbstractAdSDK {
  late final AdSDKName sdk;
  late final bool testMode;
  final maxFailedLoadAttempts = 3;
  final placements = <AdType, Placement>{};
  Function(Placement?)? onUpdate;
  final Duration waitingDuration = const Duration(milliseconds: 200);

  initialize({bool testMode = false}) {
    this.testMode = testMode;
  }

  Placement getBanner(String origin, {Size? size});

  void request(AdType type);

  Future<Placement?> show(AdType type, {String? origin});

  @protected
  void updateState(Placement placement, AdState state, [String? error]) {
    if (placement.state == state) return;
    placement.state = state;
    onUpdate?.call(placement);
    if (placement.order > 0) {}
    debugPrint(
        "Ads ==> ${placement.sdk} ${placement.type} $state ${error ?? ''}");
  }

  @protected
  waitForClose(AdType type) async {
    var myAd = placements[type]!;
    while (myAd.state == AdState.loaded || myAd.state == AdState.show) {
      debugPrint("Ads ==> _wait  ${myAd.type}  ${myAd.sdk} ${myAd.state}");
      await Future.delayed(waitingDuration);
    }
  }

  Placement? isReady(AdType type, {bool gapConsidering = false}) {
    var myAd = placements[type]!;
    if (myAd.data != null && myAd.state == AdState.loaded) {
      return myAd;
    }
    return null;
  }

  resetAd(Placement placement) async {
    placement.nativeAd?.dispose();
    placement.reward = null;
    placement.data = null;
    await Future.delayed(waitingDuration);
    request(placement.type);
  }

  @protected
  Placement findPlacement(String placementId) {
    for (var entry in placements.entries) {
      if ("adid_${sdk}_${entry.key}".l() == placementId) {
        return entry.value;
      }
    }
    return placements[AdType.rewarded]!;
  }
}
