// ignore_for_file: unused_element

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_skeleton/services/ads_service.dart';
import 'package:flutter_skeleton/services/core/iservices.dart';
import 'package:flutter_skeleton/services/trackers/tracker_gameanalytics.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../utils/device.dart';
import 'tracker_abstract.dart';
import 'tracker_firebase.dart';
import 'tracker_kochava.dart';

enum TrackerSDK { none, firebase, gameAnalytics, kochava }

enum BuildType { installed, instant }

enum ResourceFlowType { none, sink, source }

class TrackersService extends IService {
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
    await Future.delayed(const Duration(milliseconds: 200));
    debugPrint("Analytics init");

    // Initialize sdk classes
    for (var sdk in _sdks.values) {
      await sdk.initialize(args: [firebaseAnalytics]);
      var deviceId = await sdk.getDeviceId();
      if (deviceId == null) Device.adId = deviceId!;
      var variant = await sdk.getVariantId(_testName);
      if (variant == 0) this.variant = variant;
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

  Future<void> ad(MyAd ad, AdState state) async {
    for (var sdk in _sdks.values) {
      sdk.ad(ad, state);
    }
  }

  Future<void> resource(ResourceFlowType type, String currency, int amount,
      String itemType, String itemId) async {
    for (var sdk in _sdks.values) {
      sdk.resource(type, currency, amount, itemType, itemId);
    }
  }

  Future<void> design(String name, {Map<String, String>? parameters}) async {
    for (var sdk in _sdks.values) {
      sdk.design(name, parameters: parameters);
    }
  }

  Future<void> setScreen(String screenName) async {
    for (var sdk in _sdks.values) {
      sdk.setScreen(screenName);
    }
  @override
  log(log) {
    throw UnimplementedError();
  }
}
