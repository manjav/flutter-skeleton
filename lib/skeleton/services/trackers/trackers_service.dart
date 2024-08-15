import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../export.dart';

enum TrackerSDK { none, firebase, gameAnalytics, kochava, metrix, smartlook }

enum BuildType { installed, instant }

enum ResourceFlowType { none, sink, source }

class Trackers extends IService {
  final _funnelConfigs = {
    "open": [1],
    "mute_sfx": [1],
    "mute_music": [1],
    "levelup": [2, 4, 5, 10, 15, 20],
    "total_gameplay": [5, 10, 15, 30, 60],
  };

  final _sdks = <TrackerSDK, AbstractTracker>{
    TrackerSDK.firebase: FirebaseTracker(),
    // TrackerSDK.gameAnalytics: GameAnalyticsTracker(),
    // TrackerSDK.kochava: KochavaaTracker(),
    // TrackerSDK.metrix: MetrixTracker(),
    TrackerSDK.smartlook: SmartlookTracker(),
  };
  int variant = 1;
  final _testName = "_";
  final _buildType = BuildType.installed;

  Trackers();

  @override
  initialize({List<Object>? args}) async {
    if (kDebugMode) return;
    // Initialize sdk classes
    for (var sdk in _sdks.values) {
      sdk.initialize(logCallback: log);
      var variant = await sdk.getVariantId(_testName);
      if (variant != 0) this.variant = variant;
    }
  }

  // Set user data
  void sendUserData({
    required String id,
    required String name,
  }) {
    if (kDebugMode) return;
    for (var sdk in _sdks.values) {
      sdk.setProperties({
        "buildType": _buildType.name,
        "build_type": _buildType.name,
        "userId": id,
        "userName": name,
        "deviceId": DeviceInfo.adId,
        "test_name": _testName,
        "test_variant": variant.toString(),
        "appName": DeviceInfo.appName,
        "version": DeviceInfo.version,
        "buildNumber": DeviceInfo.buildNumber,
        "packageName": DeviceInfo.packageName,
      });
    }
  }

  Future<void> purchase(
      String currency,
      double amount,
      String itemId,
      String itemType,
      String receipt,
      PurchaseVerificationData verificationData) async {
    var signature = verificationData.source;
    for (var sdk in _sdks.values) {
      {
        sdk.purchase(currency, amount, itemId, itemType, receipt, signature);
      }
    }
  }

  Future<void> ad(Placement placement, AdState state) async {
    if (kDebugMode) return;
    for (var sdk in _sdks.values) {
      sdk.ad(placement, state);
    }
  }

  Future<void> design(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (kDebugMode) return;
    for (var sdk in _sdks.values) {
      sdk.design(name, parameters: parameters);
    }
  }

  Future<void> resource(
    ResourceFlowType type,
    String currency,
    int amount,
    String itemType,
    String itemId,
  ) async {
    if (kDebugMode) return;
    for (var sdk in _sdks.values) {
      sdk.resource(type, currency, amount, itemType, itemId);
    }
  }

  Future<void> setScreen(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (kDebugMode) return;
    for (var sdk in _sdks.values) {
      sdk.setScreen(screenName, parameters: parameters);
    }
  }

  void startProgress(
    String name, {
    Map<String, dynamic>? parameters,
  }) {
    if (kDebugMode) return;
    for (var sdk in _sdks.values) {
      sdk.startProgress(name, parameters: parameters);
    }
  }

  void endProgress(
    String name,
    int score, {
    Map<String, dynamic>? parameters,
  }) {
    if (kDebugMode) return;
    for (var sdk in _sdks.values) {
      sdk.endProgress(name, score, parameters: parameters);
    }
  }

  void funnel(String type, [String? name]) {
    if (kDebugMode) return;
    name = name == null ? type : "${type}_$name";
    var step = Prefs.increase(name, 1);

    // Unique events
    if (_funnelConfigs.containsKey(type)) {
      var values = _funnelConfigs[type];
      for (var value in values!) {
        if (value == step) {
          _funnel("${name}_$step");
          break;
        }
      }
    }
    _funnel(name, step);
  }

  void _funnel(String name, [int step = -1]) {
    var args = step > 0 ? {"step": '$step'} : null;
    design(name, parameters: args);
  }
}
