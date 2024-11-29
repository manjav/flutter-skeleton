import 'dart:io';

import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';

import '../../export.dart';

class AmplitudeTracker extends AbstractTracker {
  final Amplitude instance = Amplitude.getInstance();

  @override
  void initialize({List? args, Function(dynamic p1)? logCallback}) {
    sdk = TrackerSDK.amplitude;
    print("tracker_${sdk.name}_${Platform.operatingSystem}_key".l());
    instance.init("tracker_${sdk.name}_${Platform.operatingSystem}_key".l());
    super.initialize(args: args, logCallback: logCallback);
  }

  @override
  void setProperties(Map<String, String> properties) {
    instance.setUserProperties(properties);

    // instance.setUserId(properties["userId"]!);
    instance.setDeviceId(properties["deviceId"]!);

    final Identify identify = Identify();
    // identify.setOnce("userId", properties["userId"]);
    identify.setOnce("userName", properties["userName"]);
    identify.setOnce("createTime", properties["createTime"]);
    identify.set("updateTime", properties["updateTime"]);
    Amplitude.getInstance().identify(identify);

    instance.logEvent('MyApp startup',
        eventProperties: {'friend_num': 10, 'is_heavy_user': true});
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
    instance.logEvent(name, eventProperties: parameters);
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
