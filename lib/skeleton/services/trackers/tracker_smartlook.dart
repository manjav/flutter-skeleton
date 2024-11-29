import 'dart:io';

import 'package:flutter_smartlook/flutter_smartlook.dart';

import '../../../app_export.dart';

class SmartlookTracker extends AbstractTracker {
  @override
  void initialize({List? args, Function(dynamic)? logCallback}) async {
    super.initialize(args: args, logCallback: logCallback);
    sdk = TrackerSDK.smartlook;
    await Smartlook.instance.start();
    await Smartlook.instance.preferences.setProjectKey(
        "tracker_${sdk.name}_${Platform.operatingSystem}_key".l());
  }

  @override
  void setProperties(Map<String, String> properties) {
    if (properties.containsKey("userId")) {
      Smartlook.instance.user.setIdentifier(properties["userId"]!);
    }
    if (properties.containsKey("userName")) {
      Smartlook.instance.user.setName(properties["userName"]!);
    }
  }

  @override
  void ad(Placement placement, AdState state) {}

  @override
  void purchase(
    String currency,
    double amount,
    String itemId,
    String itemType,
    String receipt,
    String signature,
  ) {
    Smartlook.instance.trackEvent(
      "resource",
      properties: getProperties({
        "signature": signature,
        "currency": currency,
        "amount": amount,
        "itemType": itemType,
        "itemId": itemId
      }),
    );
  }

  @override
  void design(
    String name, {
    Map<String, dynamic>? parameters,
  }) {
    Smartlook.instance.trackEvent(
      "design$name",
      properties: getProperties(parameters),
    );
  }

  @override
  void resource(
    ResourceFlowType type,
    String currency,
    int amount,
    String itemType,
    String itemId,
  ) {
    Smartlook.instance.trackEvent(
      "resource",
      properties: getProperties({
        "flowType": type.index,
        "currency": currency, //"Gems",
        "amount": amount,
        "itemType": itemType, //"IAP",
        "itemId": itemId //"Coins400"
      }),
    );
  }

  @override
  void startProgress(
    String name, {
    Map<String, dynamic>? parameters,
  }) {
    Smartlook.instance.trackEvent(
      "progress_start_$name",
      properties: getProperties(parameters),
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
    Smartlook.instance.trackEvent(
      "progress_start_$name",
      properties: getProperties(parameters),
    );
  }

  @override
  void setScreen(String screenName, {Map<String, dynamic>? parameters}) {
    Smartlook.instance.trackEvent(
      "screen_$screenName",
      properties: getProperties(parameters),
    );
  }

  Properties? getProperties([Map<String, dynamic>? parameters]) {
    if (parameters == null) return null;
    final Properties properties = Properties();
    for (var entry in parameters.entries) {
      properties.putString(entry.key, value: "${entry.value}");
    }
    return properties;
  }
}
