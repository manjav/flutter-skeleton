import 'dart:io';

import 'package:flutter_skeleton/services/ads_service.dart';
import 'package:flutter_skeleton/services/localization_service.dart';
import 'package:flutter_skeleton/services/trackers/tracker_abstract.dart';
import 'package:kochava_tracker/kochava_tracker.dart';

import 'trackers_service.dart';

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

