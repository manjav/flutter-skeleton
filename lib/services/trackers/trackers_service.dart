// ignore_for_file: unused_element

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_skeleton/services/ads/ads_abstract.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../utils/device.dart';
import '../core/iservices.dart';
import '../prefs.dart';
import 'tracker_abstract.dart';
import 'tracker_firebase.dart';
import 'tracker_gameanalytics.dart';
import 'tracker_kochava.dart';

enum TrackerSDK { none, firebase, gameAnalytics, kochava }

extension TrackerSDKExtension on TrackerSDK {
  String get name => switch (this) {
        TrackerSDK.firebase => 'firebase',
        TrackerSDK.gameAnalytics => 'gameAnalytics',
        TrackerSDK.kochava => 'kochava',
        _ => 'none'
      };
}

enum BuildType { installed, instant }

enum ResourceFlowType { none, sink, source }

class TrackersService extends IService {
  final _funnelConfigs = {
    "open": [1],
    "mute_sfx": [1],
    "mute_music": [1],
    "levelup": [2, 4, 5, 10, 15, 20],
    "total_gameplay": [5, 10, 15, 30, 60],
  };

  final _sdks = <TrackerSDK, AbstractTracker>{
    TrackerSDK.firebase: FirebaseTracker(),
    TrackerSDK.gameAnalytics: GATracker(),
    TrackerSDK.kochava: KochavaaTracker()
  };
  final FirebaseAnalytics firebaseAnalytics;
  final _buildType = BuildType.installed;
  final _testName = "_";
  int variant = 1;

  TrackersService(this.firebaseAnalytics);

  @override
  initialize({List<Object>? args}) async {
    // Initialize sdk classes
    for (var sdk in _sdks.values) {
      await sdk.initialize(args: [firebaseAnalytics]);
      var deviceId = await sdk.getDeviceId();
      if (deviceId != null) Device.adId = deviceId;
      var variant = await sdk.getVariantId(_testName);
      if (variant != 0) this.variant = variant;
    }

    // Set user data
    for (var sdk in _sdks.values) {
      sdk.setProperties({
        'buildType': _buildType.name,
        'build_type': _buildType.name,
        'userId': '',
        'deviceId': Device.adId,
        'test_name': _testName,
        'test_variant': variant.toString(),
      });
    }
  }

  Future<void> purchase(
      String currency,
      double amount,
      String itemId,
      String itemType,
      String receipt,
      PurchaseVerificationData verificationData) async {
    var signature = verificationData.source;
    for (var sdk in _sdks.values) {
      {
        sdk.purchase(currency, amount, itemId, itemType, receipt, signature);
      }
    }
  }

  Future<void> ad(Placement placement, AdState state) async {
    for (var sdk in _sdks.values) {
      sdk.ad(placement, state);
    }
  }

  Future<void> resource(ResourceFlowType type, String currency, int amount,
      String itemType, String itemId) async {
    for (var sdk in _sdks.values) {
      sdk.resource(type, currency, amount, itemType, itemId);
    }
  }

  Future<void> design(String name, {Map<String, dynamic>? parameters}) async {
    for (var sdk in _sdks.values) {
      sdk.design(name, parameters: parameters);
    }
  }

  Future<void> setScreen(String screenName) async {
    for (var sdk in _sdks.values) {
      sdk.setScreen(screenName);
    }
  }

  // void startProgress(String name, int round, String boost) {
  //   GameAnalytics.addProgressionEvent({
  //     "progressionStatus": GAProgressionStatus.Start,
  //     "progression01": name,
  //     "progression02": "round $round",
  //     "boost": boost
  //   });
  // }

  // void endProgress(String name, int round, int score, int revives) {
  //   var map = {
  //     "progressionStatus": GAProgressionStatus.Complete,
  //     "progression01": name,
  //     "progression02": "round $round",
  //     "score": score,
  //     "revives": revives
  //   };
  //   GameAnalytics.addProgressionEvent(map);
  // }

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
    var args = step > 0 ? {"step": '$step'} : null;
    design(name, parameters: args);
  }

  @override
  log(log) {
    throw UnimplementedError();
  }
}
