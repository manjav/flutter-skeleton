import 'dart:io';

import 'package:flutter_smartlook/flutter_smartlook.dart';

import '../../app_export.dart';

class SmartlookTracker extends AbstractTracker {
  @override
  initialize({List? args, Function(dynamic)? logCallback}) async {
    super.initialize(args: args, logCallback: logCallback);
    sdk = TrackerSDK.smartlook;
    await Smartlook.instance.preferences.setProjectKey(
        "tracker_${sdk.name}_${Platform.operatingSystem}_key".l());
    await Smartlook.instance.preferences.setFrameRate(2);
    await Smartlook.instance.start();
  }

  @override
  setProperties(Map<String, String> properties) {
    Smartlook.instance.user.setIdentifier(properties["userId"]!);
    Smartlook.instance.user.setName(properties["userName"]!);
  }

  @override
  ad(Placement placement, AdState state) {}

  @override
  design(String name, {Map<String, dynamic>? parameters}) {}

  @override
  purchase(String currency, double amount, String itemId, String itemType,
      String receipt, String signature) {}

  @override
  resource(ResourceFlowType type, String currency, int amount, String itemType,
      String itemId) {}

  @override
  setScreen(String screenName) {}
}
