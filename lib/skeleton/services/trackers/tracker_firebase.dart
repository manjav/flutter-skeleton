import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:fruitcraft/main.dart';

import '../../export.dart';

class FirebaseTracker extends AbstractTracker {
  late FirebaseAnalytics _firebaseAnalytics;

  @override
  initialize({List? args, Function(dynamic)? logCallback}) {
    super.initialize(args: args, logCallback: logCallback);
    sdk = TrackerSDK.firebase;
    _firebaseAnalytics = MyApp.firebaseAnalytics;
  }

  @override
  setProperties(Map<String, String> properties) {
    for (var property in properties.entries) {
      _firebaseAnalytics.setUserProperty(
          name: property.key, value: property.value);
    }
  }

  @override
  purchase(String currency, double amount, String itemId, String itemType,
      String receipt, String signature) async {
    if (!Platform.isAndroid) {
      await _firebaseAnalytics.logPurchase(
          currency: currency,
          value: amount,
          transactionId: signature,
          coupon: receipt);
    }
  }

  @override
  ad(Placement placement, AdState state) {
    var map = <String, Object>{
      'adAction': state.name,
      'adType': placement.type.name,
      'adPlacement': placement.id,
      'adSdkName': placement.sdk.name,
    };
    _firebaseAnalytics.logEvent(name: "ads", parameters: map);
  }

  @override
  design(String name, {Map<String, dynamic>? parameters}) {
    _firebaseAnalytics.logEvent(name: name, parameters: parameters);
  }

  @override
  resource(ResourceFlowType type, String currency, int amount, String itemType,
      String itemId) {
    _firebaseAnalytics
        .logEvent(name: "resource_change", parameters: <String, dynamic>{
      "flowType": type.index,
      "currency": currency, //"Gems",
      "amount": amount,
      "itemType": itemType, //"IAP",
      "itemId": itemId //"Coins400"
    });
  }

  @override
  setScreen(String screenName) async {
    await _firebaseAnalytics.setCurrentScreen(screenName: screenName);
  }
}
