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
  }

  @override
  log(log) {
    throw UnimplementedError();
  }
}
