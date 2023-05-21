import 'dart:io';

import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_skeleton/services/core/iservices.dart';
import 'package:flutter_skeleton/services/localization_service.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';
import 'package:gameanalytics_sdk/gameanalytics.dart';
import 'package:kochava_tracker/kochava_tracker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../utils/device.dart';
import 'core/prefs.dart';

// implements IService
//Should firebase get passed to the Iservice??
abstract class AnalyticsService extends IService {
  // Future<Analytics> sendEvent();
  // init(FirebaseAnalytics firebaseAnalytics);
  funnle(String type, [String? name]);
}

class Analytics implements AnalyticsService {
  static const _testName = "_";
  late FirebaseAnalytics _firebaseAnalytics;
  int variant = 1;

  Analytics();

  final _funnelConfigs = {
    "open": [1],
    "mute_sfx": [1],
    "mute_music": [1],
    "levelup": [2, 4, 5, 10, 15, 20],
    "total_gameplay": [5, 10, 15, 30, 60],
    // "adinterstitial": [1],
    // "adrewarded": [1, 4, 10, 20, 30],
    // "adbannerclick": [1, 5, 10, 20],
  };

  @override
  initialize({List<Object>? args}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint("Analytics init");
    // var os = Platform.operatingSystem;
    // _firebaseAnalytics = args![0] as FirebaseAnalytics;
    // AppMetrica.runZoneGuarded(() {
    //   WidgetsFlutterBinding.ensureInitialized();
    //   AppMetrica.activate(AppMetricaConfig('am_key'.l(), logs: true));
    // });

    // GameAnalytics.setEnabledInfoLog(false);
    // GameAnalytics.setEnabledVerboseLog(false);
    // GameAnalytics.configureAvailableCustomDimensions01(
    //     ["installed", "instant"]);
    // GameAnalytics.configureAvailableResourceCurrencies(["coin"]);
    // GameAnalytics.configureAvailableResourceItemTypes(
    //     ["game", "confirm", "shop", "start"]);
    // var type = "installed";
    // GameAnalytics.setCustomDimension01(type);
    // AppMetrica.reportEvent("type_$type");

    // GameAnalytics.configureAutoDetectAppVersion(true);
    // GameAnalytics.initialize("ga_key_$os".l(), "ga_sec_$os".l());

    // _firebaseAnalytics.setUserProperty(name: "buildType", value: type);
    // _firebaseAnalytics.setUserProperty(name: "build_type", value: type);

    // if (Platform.isAndroid) {
    //   KochavaTracker.instance.registerAndroidAppGuid("kt_key_$os".l());
    // } else if (Platform.isIOS) {
    //   KochavaTracker.instance.registerIosAppGuid("kt_key_$os".l());
    // }
    // KochavaTracker.instance.setLogLevel(KochavaTrackerLogLevel.Warn);
    // KochavaTracker.instance.start();

    // await updateVariantIDs();
    // await getDeviceId();
    // funnle("open");

    // // Smartlook initialize
    // if (Pref.visitCount.getInt() <= 1 && Device.osVersion > 10) {
    //   // Smartlook.instance.log.enableLogging();
    //   await Smartlook.instance.preferences.setProjectKey("sl_key_$os".l());
    //   await Smartlook.instance.start();
    //   // Smartlook.instance.registerIntegrationListener(CustomIntegrationListener());
    //   // await Smartlook.instance.preferences.setWebViewEnabled(true);
    // }
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
    // if (variant == 2) {
    //   Price.ad = 40; //50 //100
    //   Price.big = 5; //10 //20
    //   Price.cube = 5; //10 //20
    //   Price.piggy = 10; //20 //40
    //   Price.record = 5; //10 //20
    //   Price.tutorial = 200; //400
    //   Price.boost = 300; // 200 //100
    //   Price.revive = 300; //200 //100
    // }

    _firebaseAnalytics.setUserProperty(name: "test_name", value: _testName);
    _firebaseAnalytics.setUserProperty(name: "test_variant", value: variantId);
    // sendDiagnosticData(version);
  }

  /*  sendDiagnosticData(String version) async {
    var url =
        "https://numbers.sarand.net/variant/?test=$_testName&variant=$variant&ads=${Ads.selectedSDK}&v=$version";
    var response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) debugPrint('Failure status code 😱');
  } */

  setAccount(dynamic account) {
    Smartlook.instance.user.setIdentifier(account.user.id);
    Smartlook.instance.user.setName(account.user.displayName);
    _firebaseAnalytics.setUserProperty(
        name: "account_id", value: account.user.id);
    GameAnalytics.configureUserId(account.user.id);
    AppMetrica.setUserProfileID(account.user.id);
  }

  Future<String> getDeviceId() async {
    var id = await KochavaTracker.instance.getDeviceId();
    if (id.isEmpty) {
      id = await AppMetrica.requestAppMetricaDeviceID();
    }
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
    // var localVerificationData = verificationData.localVerificationData;

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
      AppMetrica.reportEventWithMap("purchase", data);
      // _appsflyerSdk.validateAndLogInAppAndroidPurchase("shop_base64".l(),
      //     signature, localVerificationData, amount.toString(), currency, null);
    } else {
      await _firebaseAnalytics.logPurchase(
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
    _firebaseAnalytics.logEvent(name: "ads", parameters: map);

    GameAnalytics.addAdEvent({
      "adAction": action,
      "adType": type,
      "adSdkName": sdkName,
      "adPlacement": placementID
    });
    AppMetrica.reportEventWithMap("ads", map);
    AppMetrica.reportEventWithMap("ad_$placementID", map);

    KochavaTracker.instance.sendEventWithDictionary("ad_$placementID", map);
  }

  Future<void> resource(int type, String currency, int amount, String itemType,
      String itemId) async {
    _firebaseAnalytics
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

//NOTE this must be in the abstract class
  @override
  funnle(String type, [String? name]) {
    name = name == null ? type : "${type}_$name";
    var step = Prefs.increase(name, 1);

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
    // print("Analytics _funnle $name args $args");
    design(name, parameters: args);
  }

  Future<void> design(String name, {Map<String, dynamic>? parameters}) async {
    _firebaseAnalytics.logEvent(name: name, parameters: parameters);

    var data = {"eventId": name};
    if (parameters != null) {
      for (var k in parameters.keys) {
        data[k] = parameters[k].toString();
      }
    }
    GameAnalytics.addDesignEvent(data);
    AppMetrica.reportEventWithMap(name, data);
    KochavaTracker.instance.sendEventWithDictionary(name, data);
  }

  Future<void> share(String contentType, String itemId) async {
    // await _firebaseAnalytics.logShare(
    //     contentType: contentType, itemId: itemId, method: "");

    GameAnalytics.addDesignEvent({"eventId": "share:$contentType:$itemId"});
  }

  Future<void> setScreen(String screenName) async {
    // await _firebaseAnalytics.setCurrentScreen(screenName: screenName);

    GameAnalytics.addDesignEvent({"eventId": "screen:$screenName"});
  }

  //  Future<void> setUserProperty(String name, String value) async {
  //   await _firebaseAnalytics.setUserProperty(name: name, value: value);
  // }

  //  Future<void> tutorialBegin() async {
  //   await _firebaseAnalytics.logTutorialBegin();
  // }

  //  Future<void> tutorialComplete() async {
  //   await _firebaseAnalytics.logTutorialComplete();
  // }
  // Future<void> _testSetAnalyticsCollectionEnabled() async {
  //   await analytics.setAnalyticsCollectionEnabled(false);
  //   await analytics.setAnalyticsCollectionEnabled(true);
  //   setMessage('setAnalyticsCollectionEnabled succeeded');
  // }

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
    debugPrint(log);
  }
}
