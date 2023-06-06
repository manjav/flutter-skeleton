import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/localization_service.dart';
import 'package:flutter_skeleton/services/prefs_service.dart';
import 'package:flutter_skeleton/services/trackers/tracker_abstract.dart';
import 'package:gameanalytics_sdk/gameanalytics.dart';

import '../ads_service.dart';
import 'trackers_service.dart';

class GATracker extends AbstractTracker {
  @override
  initialize({List? args}) {
    sdk = TrackerSDK.gameAnalytics;

    GameAnalytics.setEnabledInfoLog(false);
    GameAnalytics.setEnabledVerboseLog(false);
    GameAnalytics.configureAvailableCustomDimensions01(
        [BuildType.installed.name, BuildType.instant.name]);
    // GameAnalytics.configureAvailableResourceCurrencies(["coin"]);
    // GameAnalytics.configureAvailableResourceItemTypes(
    //     ["game", "confirm", "shop", "start"]);
    // GameAnalytics.setCustomDimension01(type);

    GameAnalytics.configureAutoDetectAppVersion(true);
    GameAnalytics.initialize(
        "tracker_${sdk.name}_${Platform.operatingSystem}_key".l(),
        "tracker_${sdk.name}_${Platform.operatingSystem}_sec".l());
  }

  @override
  Future<int> getVariantId(String testName) async {
    var testVersion = ''; //PrefsService.testVersion.getString();
    var version = "app_version".l();
    debugPrint("Analytics version ==> $version testVersion ==> $testVersion");
    if (testVersion.isNotEmpty && testVersion != version) {
      return 0;
    }
    if (testVersion.isEmpty) {
      Pref.testVersion.setString(version);
    }
    var variantId =
        await GameAnalytics.getRemoteConfigsValueAsString(testName, "0");
    var variant = int.parse(variantId ?? "0");
    debugPrint("Analytics testVariantId ==> $variant");

    return variant;
  }

  @override
  setProperties(Map<String, String> properties) {
    GameAnalytics.configureUserId(properties['userId']!);
  }

  @override
  purchase(String currency, double amount, String itemId, String itemType,
      String receipt, String signature) {
    var data = {
      "currency": currency,
      "cartType": "shop",
      "amount": (amount * 100),
      "itemType": itemType,
      "itemId": itemId,
      "receipt": receipt,
      "signature": signature,
    };
    GameAnalytics.addBusinessEvent(data);
  }

  @override
  ad(MyAd ad, AdState state) {
    GameAnalytics.addAdEvent({
      "adAction": ad.state.name,
      "adType": _getGAAdType(ad.type),
      "adSdkName": ad.sdk.name,
      "adPlacement": ad.id
    });
  }

  _getGAAdType(AdType type) => switch (type) {
        AdType.interstitial => GAAdType.OfferWall,
        AdType.banner => GAAdType.Banner,
        AdType.interstitialVideo => GAAdType.Interstitial,
        AdType.rewarded => GAAdType.RewardedVideo
      };

  @override
  design(String name, {Map<String, dynamic>? parameters}) {
    GameAnalytics.addDesignEvent(parameters);
  }

  @override
  resource(ResourceFlowType type, String currency, int amount, String itemType,
      String itemId) {
    GameAnalytics.addResourceEvent({
      "flowType": type.index,
      "currency": currency, //"Gems",
      "amount": amount,
      "itemType": itemType, //"IAP",
      "itemId": itemId //"Coins400"
    });
  }

  @override
  setScreen(String screenName) {
    GameAnalytics.addDesignEvent({"eventId": "screen:$screenName"});
  }
}
