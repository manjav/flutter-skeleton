import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';

import '../../export.dart';

class FirebaseTracker extends AbstractTracker {
  static FirebaseAnalytics? _instance;
  static FirebaseAnalytics get instance =>
      _instance ??= FirebaseAnalytics.instance;

  @override
  void setProperties(Map<String, String> properties) {
    for (var property in properties.entries) {
      instance.setUserProperty(name: property.key, value: property.value);
    }
  }

  @override
  void purchase(String currency, double amount, String itemId, String itemType,
      String receipt, String signature) async {
    if (!Platform.isAndroid) {
      /*await instance.logPurchase(
          currency: currency,
          value: amount,
          transactionId: signature,
          coupon: receipt);*/
    }
  }

  @override
  void ad(Placement placement, AdState state) {
    var map = <String, Object>{
      'adAction': state.name,
      'adType': placement.type.name,
      'adPlacement': placement.id,
      'adSdkName': placement.sdk.name,
    };
    instance.logEvent(name: "ads", parameters: map);
  }

  @override
  void design(String name, {Map<String, dynamic>? parameters}) {
    instance.logEvent(
        name: name,
        parameters: parameters != null
            ? Map.castFrom<String, dynamic, String, Object>(parameters)
            : null);
  }

  @override
  void resource(ResourceFlowType type, String currency, int amount,
      String itemType, String itemId) {
    /*instance
        .logEvent(name: "resource_change", parameters: <String, dynamic>{
      "flowType": type.index,
      "currency": currency, //"Gems",
      "amount": amount,
      "itemType": itemType, //"IAP",
      "itemId": itemId //"Coins400"
    });*/
  }

  @override
  void setScreen(String screenName) async {
    // await instance.setCurrentScreen(screenName: screenName);
  }
}
