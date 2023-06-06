import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import '../services/core/iservices.dart';
import '../services/localization_service.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:gameanalytics_sdk/gameanalytics.dart';
import 'package:kochava_tracker/kochava_tracker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../utils/device.dart';
import 'prefs_service.dart';

abstract class AnalyticsService extends IService {
  funnle(String type, [String? name]);
  Future<void> design(String name, {Map<String, dynamic>? parameters});
}

class Analytics implements AnalyticsService {
  static const _testName = "_";
  final FirebaseAnalytics firebaseAnalytics;
  int variant = 1;

  Analytics(this.firebaseAnalytics);

  final _funnelConfigs = {
    "open": [1],
    "mute_sfx": [1],
    "mute_music": [1],
    "levelup": [2, 4, 5, 10, 15, 20],
    "total_gameplay": [5, 10, 15, 30, 60],
  };

  @override
  initialize({List<Object>? args}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint("Analytics init");
    var os = Platform.operatingSystem;
    // AppMetrica.runZoneGuarded(() {
    //   WidgetsFlutterBinding.ensureInitialized();
    //   AppMetrica.activate(AppMetricaConfig('am_key'.l(), logs: true));
    // });

    GameAnalytics.setEnabledInfoLog(false);
    GameAnalytics.setEnabledVerboseLog(false);
    GameAnalytics.configureAvailableCustomDimensions01(
        ["installed", "instant"]);
    GameAnalytics.configureAvailableResourceCurrencies(["coin"]);
    GameAnalytics.configureAvailableResourceItemTypes(
        ["game", "confirm", "shop", "start"]);
    var type = "installed";
    GameAnalytics.setCustomDimension01(type);
    // AppMetrica.reportEvent("type_$type");

    GameAnalytics.configureAutoDetectAppVersion(true);
    GameAnalytics.initialize("ga_key_$os".l(), "ga_sec_$os".l());

    firebaseAnalytics.setUserProperty(name: "buildType", value: type);
    firebaseAnalytics.setUserProperty(name: "build_type", value: type);

    if (Platform.isAndroid) {
      KochavaTracker.instance.registerAndroidAppGuid("kt_key_$os".l());
    } else if (Platform.isIOS) {
      KochavaTracker.instance.registerIosAppGuid("kt_key_$os".l());
    }
    KochavaTracker.instance.setLogLevel(KochavaTrackerLogLevel.Warn);
    KochavaTracker.instance.start();

    await updateVariantIDs();
    await getDeviceId();
    funnle("open");

    // Smartlook initialize
    if (Pref.visitCount.getInt() <= 1 && Device.osVersion > 10) {
      await Smartlook.instance.preferences.setProjectKey("sl_key_$os".l());
      await Smartlook.instance.start();
    }
  }

  updateVariantIDs() async {
    var testVersion = Pref.testVersion.getString();
    var version = "app_version".l();
    debugPrint("Analytics version ==> $version testVersion ==> $testVersion");
    if (testVersion.isNotEmpty && testVersion != version) {
      return;
    }
    if (testVersion.isEmpty) {
      Pref.testVersion.setString(version);
    }
    var variantId =
        await GameAnalytics.getRemoteConfigsValueAsString(_testName, "0");
    variant = int.parse(variantId ?? "0");
    debugPrint("Analytics testVariantId ==> $variant");

    firebaseAnalytics.setUserProperty(name: "test_name", value: _testName);
    firebaseAnalytics.setUserProperty(name: "test_variant", value: variantId);
  }

  setAccount(dynamic account) {
    Smartlook.instance.user.setIdentifier(account.user.id);
    Smartlook.instance.user.setName(account.user.displayName);
    firebaseAnalytics.setUserProperty(
        name: "account_id", value: account.user.id);
    GameAnalytics.configureUserId(account.user.id);
    // AppMetrica.setUserProfileID(account.user.id);
  }

  Future<String> getDeviceId() async {
    var id = await KochavaTracker.instance.getDeviceId();
    // if (id.isEmpty) {
    //   id = await AppMetrica.requestAppMetricaDeviceID();
    // }
    if (id.isEmpty) {
      id = Device.id;
    }
    return Device.adId = id;
  }

  Future<void> purchase(
      String currency,
      double amount,
      String itemId,
      String itemType,
      String receipt,
      PurchaseVerificationData verificationData) async {
    var signature = verificationData.source;

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

    if (Platform.isAndroid) {
      // AppMetrica.reportEventWithMap("purchase", data);
    } else {
      await firebaseAnalytics.logPurchase(
          currency: currency,
          value: amount,
          transactionId: signature,
          coupon: receipt);
    }
  }

  Future<void> ad(
      int action, int type, String placementID, String sdkName) async {
    var map = <String, Object>{
      'adAction': getAdActionName(action),
      'adType': getAdTypeName(type),
      'adPlacement': placementID,
      'adSdkName': sdkName,
    };
    firebaseAnalytics.logEvent(name: "ads", parameters: map);

    GameAnalytics.addAdEvent({
      "adAction": action,
      "adType": type,
      "adSdkName": sdkName,
      "adPlacement": placementID
    });
    // AppMetrica.reportEventWithMap("ads", map);
    // AppMetrica.reportEventWithMap("ad_$placementID", map);

    KochavaTracker.instance.sendEventWithDictionary("ad_$placementID", map);
  }

  Future<void> resource(int type, String currency, int amount, String itemType,
      String itemId) async {
    firebaseAnalytics
        .logEvent(name: "resource_change", parameters: <String, dynamic>{
      "flowType": getResourceType(type),
      "currency": currency, //"Gems",
      "amount": amount,
      "itemType": itemType, //"IAP",
      "itemId": itemId //"Coins400"
    });

    GameAnalytics.addResourceEvent({
      "flowType": type,
      "currency": currency, //"Gems",
      "amount": amount,
      "itemType": itemType, //"IAP",
      "itemId": itemId //"Coins400"
    });
  }

  void startProgress(String name, int round, String boost) {
    GameAnalytics.addProgressionEvent({
      "progressionStatus": GAProgressionStatus.Start,
      "progression01": name,
      "progression02": "round $round",
      "boost": boost
    });
  }

  void endProgress(String name, int round, int score, int revives) {
    var map = {
      "progressionStatus": GAProgressionStatus.Complete,
      "progression01": name,
      "progression02": "round $round",
      "score": score,
      "revives": revives
    };
    GameAnalytics.addProgressionEvent(map);
  }

  @override
  funnle(String type, [String? name]) {
    name = name == null ? type : "${type}_$name";
    var step = PrefsService.increase(name, 1);

    // Unique events
    if (_funnelConfigs.containsKey(type)) {
      var values = _funnelConfigs[type];

      for (var value in values!) {
        if (value == step) {
          _funnle("${name}_$step");
          break;
        }
      }
    }
    _funnle(name, step);
  }

  _funnle(String name, [int step = -1]) {
    var args = step > 0 ? {"step": step} : null;
    design(name, parameters: args);
  }

  @override
  Future<void> design(String name, {Map<String, dynamic>? parameters}) async {
    firebaseAnalytics.logEvent(name: name, parameters: parameters);

    var data = {"eventId": name};
    if (parameters != null) {
      for (var k in parameters.keys) {
        data[k] = parameters[k].toString();
      }
    }
    GameAnalytics.addDesignEvent(data);
    // AppMetrica.reportEventWithMap(name, data);
    KochavaTracker.instance.sendEventWithDictionary(name, data);
  }

  Future<void> share(String contentType, String itemId) async {
    GameAnalytics.addDesignEvent({"eventId": "share:$contentType:$itemId"});
  }

  Future<void> setScreen(String screenName) async {
    GameAnalytics.addDesignEvent({"eventId": "screen:$screenName"});
  }

  String getAdActionName(int action) {
    switch (action) {
      case GAAdAction.Clicked:
        return "Clicked";
      case GAAdAction.Show:
        return "Show";
      case GAAdAction.FailedShow:
        return "FailedShow";
      case GAAdAction.RewardReceived:
        return "RewardReceived";
      case GAAdAction.Request:
        return "Request";
      default:
        return "Loaded";
    }
  }

  String getAdTypeName(int type) {
    switch (type) {
      case GAAdType.Video:
        return "Video";
      case GAAdType.RewardedVideo:
        return "RewardedVideo";
      case GAAdType.Playable:
        return "Playable";
      case GAAdType.Interstitial:
        return "Interstitial";
      case GAAdType.OfferWall:
        return "OfferWall";
      default:
        return "Banner";
    }
  }

  String getResourceType(int type) {
    switch (type) {
      case GAResourceFlowType.Sink:
        return "Sink";
      default:
        return "Source";
    }
  }

  @override
  log(log) {
    throw UnimplementedError();
  }
}
