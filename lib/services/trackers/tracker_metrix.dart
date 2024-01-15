import 'dart:io';

import 'package:metrix_plugin/Metrix.dart';

import '../../app_export.dart';

class MetrixTracker extends AbstractTracker {
  static const _prefix = "tracker_metrix_";
  @override
  initialize({List? args, Function(dynamic)? logCallback}) {
    super.initialize(args: args, logCallback: logCallback);
    if (Platform.isIOS) {
      Metrix.initialize("${_prefix}app_id".l());
    }
  }

  @override
  Future<String?> getDeviceId() async => null;

  @override
  setProperties(Map<String, String> properties) {}

  @override
  purchase(String currency, double amount, String itemId, String itemType,
      String receipt, String signature) async {
    Metrix.newEvent("${_prefix}has_purchase".l());
    Metrix.newEvent("${_prefix}purchase".l(), {
      "currency": currency,
      "cartType": "shop",
      "amount": "$amount",
      "itemType": itemType,
      "itemId": itemId,
      "receipt": receipt,
      "signature": signature,
    });
  }

  @override
  ad(Placement placement, AdState state) {
    if (placement.type == AdType.rewarded) {
      Metrix.newEvent(
          "${_prefix}rewarded_${Platform.operatingSystem.toLowerCase()}",
          <String, String>{
            "adAction": state.name,
            "adPlacement": placement.id,
            "adType": placement.type.name,
            "adSdkName": placement.sdk.name,
          });
    }
  }

  @override
  design(String name, {Map<String, dynamic>? parameters}) {
    name = "$_prefix$name".l();
    if (parameters != null) {
      Metrix.newEvent(
          name, Map.castFrom<String, dynamic, String, String>(parameters));
    } else {
      Metrix.newEvent(name);
    }
  }

  @override
  resource(ResourceFlowType type, String currency, int amount, String itemType,
      String itemId) {}

  @override
  setScreen(String screenName) async {}
}
