import 'package:flutter/material.dart';

import '../../mixins/ilogger.dart';
import '../localization.dart';

enum AdSDKName { none, adivery, applovin, google, unity }

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
  native,
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
    id = "adid_${sdk.name}_${type.name}".l();
  }
  int get order {
    if (state == AdState.failedLoad) return -1;
    return state.index;
  }
}

abstract class AbstractAdSDK with ILogger {
  late final AdSDKName sdk;
  late final bool testMode;
  final maxFailedLoadAttempts = 3;
  late final Map<AdType, Placement> placements;
  Function(Placement?)? onUpdate;
  final Duration waitingDuration = const Duration(milliseconds: 200);

  initialize(AdSDKName sdk, {bool testMode = false}) {
    this.testMode = testMode;
    placements = {
      AdType.interstitial: Placement(sdk, AdType.interstitial),
      AdType.native: Placement(sdk, AdType.native),
      AdType.rewarded: Placement(sdk, AdType.rewarded),
    };
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
    log("${placement.sdk} ${placement.type} $state ${error ?? ''}");
  }

  @protected
  waitForClose(AdType type) async {
    var myAd = placements[type]!;
    while (myAd.state == AdState.loaded || myAd.state == AdState.show) {
      log("wait  ${myAd.type}  ${myAd.sdk} ${myAd.state}");
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
