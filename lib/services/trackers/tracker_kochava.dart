import 'dart:io';

import 'package:kochava_tracker/kochava_tracker.dart';

import '../ads/ads_abstract.dart';
import '../localization.dart';
import 'tracker_abstract.dart';
import 'trackers.dart';

class KochavaaTracker extends AbstractTracker {
  @override
  initialize({List? args}) {
    sdk = TrackerSDK.kochava;
    if (Platform.isAndroid) {
      KochavaTracker.instance.registerAndroidAppGuid(
          "tracker_${sdk.name}_${Platform.operatingSystem}_key".l());
    } else if (Platform.isIOS) {
      KochavaTracker.instance.registerIosAppGuid(
          "tracker_${sdk.name}_${Platform.operatingSystem}_key".l());
    }
    KochavaTracker.instance.setLogLevel(KochavaTrackerLogLevel.Warn);
    KochavaTracker.instance.start();
  }

  @override
  Future<String?> getDeviceId() async {
    return await KochavaTracker.instance.getDeviceId();
  }

  @override
  setProperties(Map<String, String> properties) {}

  @override
  purchase(String currency, double amount, String itemId, String itemType,
      String receipt, String signature) async {}

  @override
  ad(Placement placement, AdState state) {
    var map = <String, Object>{
      'adAction': state.name,
      'adType': placement.type.name,
      'adPlacement': placement.id,
      'adSdkName': placement.sdk.name,
    };
    KochavaTracker.instance.sendEventWithDictionary("ad_${placement.id}", map);
  }

  @override
  design(String name, {Map<String, dynamic>? parameters}) {
    KochavaTracker.instance.sendEventWithDictionary(name, parameters!);
  }

  @override
  resource(ResourceFlowType type, String currency, int amount, String itemType,
      String itemId) {}

  @override
  setScreen(String screenName) async {}
}
