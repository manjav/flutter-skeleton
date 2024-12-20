import 'dart:io';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:amplitude_flutter/events/base_event.dart';
import 'package:amplitude_flutter/events/identify.dart';

import '../../export.dart';

class AmplitudeTracker extends AbstractTracker {
  late final Amplitude instance;
  @override
  Future<void> initialize(
      {List? args, Function(dynamic p1)? logCallback}) async {
    sdk = TrackerSDK.amplitude;
    instance = Amplitude(Configuration(
      apiKey: "tracker_${sdk.name}_${Platform.operatingSystem}_key".l(),
      flushIntervalMillis: 1000,
      flushQueueSize: 1,
    ));
    await instance.isBuilt;

    super.initialize(args: args, logCallback: logCallback);
  }

  @override
  void setProperties(Map<String, String> properties) {
    // User properties
    final identify = Identify();
    final allowedKeys = {"build_type", "native_language", "content_version"};
    for (var key in allowedKeys) {
      if (properties.containsKey(key)) {
        identify.set(key, properties[key]);
      }
    }
    for (var e in properties.entries) {
      if (e.key.startsWith("rc_")) {
        identify.set(e.key, e.value);
      }
    }
    instance.identify(identify);

    // User Id
    if (properties.containsKey("userId")) {
      instance.setUserId(properties["userId"]!);
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
    //   if (!Platform.isAndroid) {
    //     await instance.logPurchase(
    //       currency: currency,
    //       value: amount,
    //       transactionId: signature,
    //       coupon: receipt,
    //     );
    //   }
  }

  @override
  void ad(Placement placement, AdState state) {
    //   var map = <String, Object>{
    //     'adAction': state.name,
    //     'adType': placement.type.name,
    //     'adPlacement': placement.id,
    //     'adSdkName': placement.sdk.name,
    //   };
    //   instance.logEvent(name: "ads", parameters: map);
  }

  @override
  void design(
    String name, {
    Map<String, dynamic>? parameters,
  }) {
    instance.track(BaseEvent(name, eventProperties: parameters));
  }

  @override
  void resource(
    ResourceFlowType type,
    String currency,
    int amount,
    String itemType,
    String itemId,
  ) {
    // instance.logEvent(name: "resource_change", parameters: <String, Object>{
    //   "flowType": type.index,
    //   "currency": currency, //"Gems",
    //   "amount": amount,
    //   "itemType": itemType, //"IAP",
    //   "itemId": itemId //"Coins400"
    // });
  }

  @override
  void startProgress(
    String name, {
    Map<String, dynamic>? parameters,
  }) {
    // instance.logEvent(
    //   name: "progress_start_$name",
    //   parameters: convertMap(parameters),
    // );
  }

  @override
  void endProgress(
    String name,
    int score, {
    Map<String, dynamic>? parameters,
  }) {
    // parameters ??= {};
    // parameters["score"] = score;
    // instance.logEvent(
    //   name: "progress_start_$name",
    //   parameters: convertMap(parameters),
    // );
  }

  @override
  void setScreen(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    // await instance.logScreenView(
    //   screenName: screenName,
    //   parameters: convertMap(parameters),
    // );
  }
}
