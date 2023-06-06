import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/localization_service.dart';
import 'package:flutter_skeleton/services/prefs_service.dart';
import 'package:flutter_skeleton/services/trackers/tracker_abstract.dart';
import 'package:gameanalytics_sdk/gameanalytics.dart';

import '../ads_service.dart';
import 'trackers_service.dart';

class GATracker extends AbstractTracker {
  @override
  initialize({List? args}) {
    sdk = TrackerSDK.gameAnalytics;

    GameAnalytics.setEnabledInfoLog(false);
    GameAnalytics.setEnabledVerboseLog(false);
    GameAnalytics.configureAvailableCustomDimensions01(
        [BuildType.installed.name, BuildType.instant.name]);
    // GameAnalytics.configureAvailableResourceCurrencies(["coin"]);
    // GameAnalytics.configureAvailableResourceItemTypes(
    //     ["game", "confirm", "shop", "start"]);
    // GameAnalytics.setCustomDimension01(type);

    GameAnalytics.configureAutoDetectAppVersion(true);
    GameAnalytics.initialize(
        "tracker_${sdk.name}_${Platform.operatingSystem}_key".l(),
        "tracker_${sdk.name}_${Platform.operatingSystem}_sec".l());
  }

