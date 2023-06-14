import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/ads/ads_adivery.dart';

import '../core/iservices.dart';
import 'ads_abstract.dart';

class AdsService extends IService {
  final _sdks = <AdSDKName, AbstractAdSDK>{};
  final _selectedSDK = AdSDKName.adivery;
  Function(Placement?)? onUpdate;

  @override
  initialize({List<Object>? args}) async {
    debugPrint("ads init");
    _sdks[_selectedSDK] = AdAdivery();
    _sdks[_selectedSDK]!.initialize(_selectedSDK);
    _sdks[_selectedSDK]!.onUpdate = (p) => onUpdate?.call(p);
    super.initialize();
  }

  void isReady(AdType type) => _sdks[_selectedSDK]!.isReady(type);

  Widget getBanner(String origin, {Size? size}) {
    var placement = _sdks[_selectedSDK]!.getBanner(origin, size: size);
    var width = placement.nativeAd.size.width.toDouble();
    var height = placement.nativeAd.size.height.toDouble();
    return SizedBox(width: width, height: height, child: placement.nativeAd);
  }

  void request(AdType type) => _sdks[_selectedSDK]!.request(type);

  Future<Placement?> show(AdType type, {String? origin}) =>
      _sdks[_selectedSDK]!.show(type, origin: origin);

  void resumeApp() {
    // _myAds.forEach((key, value) {
    //   if (value.type != AdType.banner && value.state == AdState.show) {}
    // });
  }

  @override
  log(log) {
    debugPrint(log);
    // sound.log("*-sound inside ads log");
  }
}
