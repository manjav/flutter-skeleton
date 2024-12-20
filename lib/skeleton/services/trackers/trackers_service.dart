import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lifetalk/skeleton/services/trackers/tracker_amplitude.dart';

import '../../export.dart';

enum TrackerSDK { none, firebase, smartlook, amplitude }

enum BuildType { installed, instant }

enum ResourceFlowType { none, sink, source }

class Trackers extends IService {
  final _funnelConfigs = {
    "open": [1],
    "levelup": [2, 4, 5, 10, 15, 20],
    "total_gameplay": [5, 10, 15, 30, 60],
  };

  final _sdks = <TrackerSDK, AbstractTracker>{
    TrackerSDK.firebase: FirebaseTracker(),
    TrackerSDK.amplitude: AmplitudeTracker(),
    TrackerSDK.smartlook: SmartlookTracker(),
  };
  Map<String, dynamic> remoteConfigs = {};
  final _buildType = BuildType.installed;
  bool get ghostMode =>
      kDebugMode || Pref.username.getString().startsWith("test_");

  Trackers();

  @override
  initialize({List<Object>? args}) async {
    if (ghostMode) return;
    // Initialize sdk classes
    for (var sdk in _sdks.values) {
      sdk.initialize(logCallback: log);
      var remoteConfigs = await sdk.getRemoteConfigs();
      if (remoteConfigs.isNotEmpty) {
        this.remoteConfigs = remoteConfigs;
      }
    }
  }

  // Set user data
  void sendUserData({
    String? userId,
    String? userName,
    String? nativeLanguage,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    if (ghostMode) return;
    for (var sdk in _sdks.values) {
      final properties = {
        "buildType": _buildType.name,
        "build_type": _buildType.name,
        "device_id": DeviceInfo.adId,
        "app_name": DeviceInfo.appName,
        // "version": DeviceInfo.version,
        "build_Number": DeviceInfo.buildNumber,
        // "packageName": DeviceInfo.packageName,
        "content_version": "content_version".l(),
      };
      if (userId != null) properties["userId"] = userId;
      if (userName != null) properties["userName"] = userName;
      if (nativeLanguage != null) {
        properties["native_language"] = nativeLanguage;
      }
      for (var e in remoteConfigs.entries) {
        if (e.value is String || e.value is num || e.value is bool) {
          properties["rc_${e.key}"] = e.value.toString();
        }
      }
      sdk.setProperties(properties);
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
    if (ghostMode) return;
    for (var sdk in _sdks.values) {
      sdk.ad(placement, state);
    }
  }

  Future<void> design(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    // log("amp => $name ${jsonEncode(parameters)}");
    if (ghostMode) return;
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
    if (ghostMode) return;
    for (var sdk in _sdks.values) {
      sdk.resource(type, currency, amount, itemType, itemId);
    }
  }

  Future<void> setScreen(
    String screenName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (ghostMode) return;
    for (var sdk in _sdks.values) {
      sdk.setScreen(screenName, parameters: parameters);
    }
  }

  void startProgress(
    String name, {
    Map<String, dynamic>? parameters,
  }) {
    if (ghostMode) return;
    for (var sdk in _sdks.values) {
      sdk.startProgress(name, parameters: parameters);
    }
  }

  void endProgress(
    String name,
    int score, {
    Map<String, dynamic>? parameters,
  }) {
    if (ghostMode) return;
    for (var sdk in _sdks.values) {
      sdk.endProgress(name, score, parameters: parameters);
    }
  }

  void funnel(String type, [String? name]) {
    if (ghostMode) return;
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
