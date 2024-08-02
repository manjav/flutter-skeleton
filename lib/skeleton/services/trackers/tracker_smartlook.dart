import 'dart:io';

import 'package:flutter_smartlook/flutter_smartlook.dart';

import '../../../app_export.dart';

class SmartlookTracker extends AbstractTracker {
  @override
  void initialize({List? args, Function(dynamic)? logCallback}) async {
    super.initialize(args: args, logCallback: logCallback);
    sdk = TrackerSDK.smartlook;
    await Smartlook.instance.start();
    await Smartlook.instance.preferences.setProjectKey(
        "tracker_${sdk.name}_${Platform.operatingSystem}_key".l());
  }

  @override
  void setProperties(Map<String, String> properties) {
    Smartlook.instance.user.setIdentifier(properties["userId"]!);
    Smartlook.instance.user.setName(properties["userName"]!);
  }

  @override
  void ad(Placement placement, AdState state) {}

  @override
  void design(String name, {Map<String, dynamic>? parameters}) {}

  @override
  void purchase(String currency, double amount, String itemId, String itemType,
      String receipt, String signature) {}

  @override
  void resource(ResourceFlowType type, String currency, int amount,
      String itemType, String itemId) {}

  @override
  void setScreen(String screenName) {}
}
