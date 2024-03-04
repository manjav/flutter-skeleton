import 'purchase.dart';
import 'sku_details.dart';

class Inventory {
  Map<String, Purchase> mPurchaseMap = {};
  Map<String, SkuDetails> mSkuMap = {};

  Inventory();

  factory Inventory.fromJson(Map<String, dynamic> json) => Inventory()
    ..mPurchaseMap = {
      for (var i in json["mPurchaseMap"].entries)
        i.key: Purchase.fromJson(i.value)
    }
    ..mSkuMap = {
      for (var i in json["mSkuMap"].entries) i.key: SkuDetails.fromMap(i.value)
    };

  Map<String, dynamic> toJson() => {
        'mPurchaseMap': mPurchaseMap,
        'mSkuMap': mSkuMap,
      };

  @override
  String toString() {
    return 'Inventory{mPurchaseMap: $mPurchaseMap, mSkuMap: $mSkuMap}';
  }
}
