// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/services.dart';

import '../app_export.dart';

class Payment extends IService {
  final String PURCHASE = "purchase";
  final String INVENTORY = "inventory";
  final String RESULT = "result";
  IabResult? iabResult;
  final MethodChannel _channel = const MethodChannel(
      'com.tcg.fruitcraft.trading.card.game.battle/payment');

  Future<void> init({
    required String storePackageName,
    required String bindUrl,
    bool enableDebugLogging = false,
  }) async {
    var iabResult = await _channel.invokeMethod("init", <String, dynamic>{
      "storePackageName": storePackageName,
      "bindUrl": bindUrl,
      'enableDebugLogging': true,
    });
    var iabResultJson = iabResult != null ? json.decode(iabResult) : null;
    this.iabResult =
        iabResultJson != null ? IabResult.fromJson(iabResultJson) : null;
    super.initialize();
  }

  Future<Map> launchPurchaseFlow({required String sku, String? payload}) async {
    var map =
        await _channel.invokeMethod("launchPurchaseFlow", <String, dynamic>{
      'sku': sku,
      'payload': payload,
    });
    var purchaseJson = json.decode(map["purchase"]);
    var resultJson = json.decode(map["result"]);

    return {
      RESULT: resultJson != null ? IabResult.fromJson(resultJson) : null,
      PURCHASE: purchaseJson != null ? Purchase.fromJson(purchaseJson) : null,
    };
  }

  Future<Map> consume({required Purchase purchase}) async {
    var map = await _channel.invokeMethod("consume", <String, dynamic>{
      'purchase': json.encode(purchase.toJson()),
    });
    var purchaseJson = json.decode(map["purchase"]);
    var resultJson = json.decode(map["result"]);
    return {
      RESULT: resultJson != null ? IabResult.fromJson(resultJson) : null,
      PURCHASE: purchaseJson != null ? Purchase.fromJson(purchaseJson) : null,
    };
  }

  Future<Map> getPurchase(
      {required String sku, bool querySkuDetails = false}) async {
    var map = await _channel.invokeMethod("getPurchase", <String, dynamic>{
      'sku': sku,
      'querySkuDetails': querySkuDetails,
    });
    var purchaseJson = json.decode(map["purchase"]);
    var resultJson = json.decode(map["result"]);
    return {
      RESULT: resultJson != null ? IabResult.fromJson(resultJson) : null,
      PURCHASE: purchaseJson != null ? Purchase.fromJson(purchaseJson) : null,
    };
  }

  Future<Map> queryInventory(
      {bool querySkuDetails = false, List<String>? skus}) async {
    var map = await _channel.invokeMethod("queryInventory",
        <String, dynamic>{'querySkuDetails': querySkuDetails, 'skus': skus});
    var purchaseJson = json.decode(map["inventory"]);
    var resultJson = json.decode(map["result"]);
    return {
      RESULT: resultJson != null ? IabResult.fromJson(resultJson) : null,
      INVENTORY: purchaseJson != null ? Inventory.fromJson(purchaseJson) : null,
    };
  }

  bool get isAvailable => iabResult != null && iabResult!.isSuccess();

  Future dispose() async {
    return await _channel.invokeMethod("dispose");
  }
}
