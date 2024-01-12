import 'dart:io';

import 'package:gameanalytics_sdk/gameanalytics.dart';

import '../../skeleton/services/ads/ads_abstract.dart';
import '../../skeleton/services/localization.dart';
import '../../skeleton/services/trackers/tracker_abstract.dart';
import '../../skeleton/services/trackers/trackers.dart';

class GameAnalyticsTracker extends AbstractTracker {
  @override
  initialize({List? args, Function(dynamic)? logCallback}) {
    super.initialize(args: args, logCallback: logCallback);
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
    // var testVersion = Pref.testVersion.getString();
    // var version = DeviceInfo.packageInfo.buildNumber;
    // log("version ==> $version testVersion ==> $testVersion");
    // if (testVersion.isNotEmpty && testVersion != version) {
    //   return 0;
    // }
    // if (testVersion.isEmpty) {
    //   Pref.testVersion.setString(version);
    // }
    // var variantId =
    //     await GameAnalytics.getRemoteConfigsValueAsString(testName, "0");
    // var variant = int.parse(variantId ?? "0");
    // log("testVariantId ==> $variant");

    return 0; //variant;
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
  ad(Placement placement, AdState state) {
    GameAnalytics.addAdEvent({
      "adAction": placement.state.name,
      "adType": _getGAAdType(placement.type),
      "adSdkName": placement.sdk.name,
      "adPlacement": placement.id
    });
  }

  _getGAAdType(AdType type) => switch (type) {
        AdType.banner => GAAdType.Banner,
        AdType.interstitial => GAAdType.OfferWall,
        AdType.interstitialVideo => GAAdType.Interstitial,
        AdType.native => GAAdType.Playable,
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
