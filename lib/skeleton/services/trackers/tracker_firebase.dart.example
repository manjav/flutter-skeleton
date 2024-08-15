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
  void purchase(
    String currency,
    double amount,
    String itemId,
    String itemType,
    String receipt,
    String signature,
  ) async {
    if (!Platform.isAndroid) {
      await instance.logPurchase(
        currency: currency,
        value: amount,
        transactionId: signature,
        coupon: receipt,
      );
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
  void design(
    String name, {
    Map<String, dynamic>? parameters,
  }) {
    instance.logEvent(name: name, parameters: convertMap(parameters));
  }

  @override
  void resource(
    ResourceFlowType type,
    String currency,
    int amount,
    String itemType,
    String itemId,
  ) {
    instance.logEvent(name: "resource_change", parameters: <String, Object>{
      "flowType": type.index,
      "currency": currency, //"Gems",
      "amount": amount,
      "itemType": itemType, //"IAP",
      "itemId": itemId //"Coins400"
    });
  }

  @override
  void startProgress(
    String name, {
    Map<String, dynamic>? parameters,
  }) {
    instance.logEvent(
      name: "progress_start_$name",
      parameters: convertMap(parameters),
    );
  }

  @override
  void endProgress(
    String name,
    int score, {
    Map<String, dynamic>? parameters,
  }) {
    parameters ??= {};
    parameters["score"] = score;
    instance.logEvent(
      name: "progress_start_$name",
      parameters: convertMap(parameters),
    );
  }

  @override
  void setScreen(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    await instance.logScreenView(
      screenName: screenName,
      parameters: convertMap(parameters),
    );
  }
}
