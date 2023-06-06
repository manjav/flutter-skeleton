import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_skeleton/services/ads_service.dart';
import 'package:flutter_skeleton/services/trackers/tracker_abstract.dart';

import 'trackers_service.dart';

class FirebaseTracker extends AbstractTracker {
  late FirebaseAnalytics _firebaseAnalytics;

  @override
  initialize({List? args}) {
    sdk = TrackerSDK.gameAnalytics;
    _firebaseAnalytics = args![0] as FirebaseAnalytics;
  }

  @override
  setProperties(Map<String, String> properties) {
    for (var property in properties.entries) {
      _firebaseAnalytics.setUserProperty(
          name: property.key, value: property.value);
    }
  }
