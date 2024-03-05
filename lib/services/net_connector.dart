import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:nakama/nakama.dart';

import '../../app_export.dart';

class NetConnector extends IService {
  NakamaGrpcClient? _nakamaClient;
  static Map<String, dynamic> configs = {};
  Session? _session;

  @override
  initialize({List<Object>? args}) async {
    var version = int.parse(DeviceInfo.buildNumber);
    await _loadConfigs(version);

      _session = await connect();
    var account = await getAccount();

      // // Check internal version, public users avoidance
      // var test = _config["updates"]["test"];
      // if (test["version"] < version) {
      //   if (!test["testers"].contains(loadData.account.id)) {
      //     throw SkeletonException(StatusCode.C702_UPDATE_TEST.value, "");
      //   }
      // }
    super.initialize();
    return account;
  }

  Future<void> _loadConfigs(int version) async {
    http.Response? response;
    try {
      response = await http.get(
          Uri.parse("https://8ball.turnedondigital.com/lingai/configs.json"));
    } catch (e) {
      var error = "$e";
      if (_isDisconnected(error)) {
        throw SkeletonException(
            StatusCode.C503_SERVICE_UNAVAILABLE.value, error);
      }
    }
    if (response!.statusCode == 200) {
      configs = json.decode(utf8.decode(response.bodyBytes));
      var updates = configs["updates"];
      if (updates["force"]["version"] > version) {
        throw SkeletonException(
            StatusCode.C701_UPDATE_FORCE.value, updates["force"]["message"]);
      } else if (!Pref.skipUpdate.getBool() &&
          updates["notice"]["version"] > version) {
        throw SkeletonException(
            StatusCode.C700_UPDATE_NOTICE.value, updates["notice"]["message"]);
      }
      Pref.skipUpdate.setBool(false);
      LoaderWidget.baseURL = configs["assetsServer"]!;
      LoaderWidget.hashMap = Map.castFrom(configs["files"]);
      log("Config loaded.");
    } else {
      throw SkeletonException(
          StatusCode.C999_UNKNOWN_ERROR.value, "Failed to load config file");
    }
  }

  // Connect to nakama server
  Future<Session> connect() async {
    _nakamaClient = NakamaGrpcClient(
        host: "192.168.1.133" /* configs["host"] */,
        port: configs["port"],
        serverKey: "defaultkey",
        ssl: false);

    var timezone = DateTime.now().timeZoneOffset.inSeconds;
    var location = await FlutterTimezone.getLocalTimezone();
    var store = "GooglePlay";
    var data = {
      "store": store,
      "location": location,
      "timezone": "$timezone",
      "latestVersion": DeviceInfo.buildNumber,
      "displayName": "Player_${StringExtension.getRandomString(4)}",
      "device":
          '{"model":"${DeviceInfo.model}", "osVersion":"${DeviceInfo.osVersion}", "baseVersion":"${DeviceInfo.baseVersion}"}'
    };

    try {
      var session = await _nakamaClient!
          .authenticateDevice(deviceId: DeviceInfo.adId, vars: data);
      return session;
    } catch (e) {
      throw SkeletonException(-1, e.toString());
    }
  }

  refreshAccount() async {
    account = await _nakamaClient!.getAccount(_session!);
  }

  Future<void> updateAccount({String? displayName, String? avatarUrl}) async {
    await _nakamaClient!.updateAccount(
        session: _session!, displayName: displayName, avatarUrl: avatarUrl);
    await refreshAccount();
  }

  Future<T> tryRpc<T>(BuildContext context, String id, {Map? params}) async {
    dynamic result;
    try {
      result = await rpc<T>(id, params: params);
    } on SkeletonException catch (e) {
      if (context.mounted) {
        await serviceLocator<RouteService>().to(Routes.popupMessage,
            args: {"title": "Error", "message": "error_${e.statusCode}".l()});
      }
      rethrow;
    }
    return result;
  }

  Future<T> rpc<T>(String id, {Map? params}) async {
    params = params ?? {};
    try {
      var data = await _nakamaClient!
          .rpc(session: _session!, id: id, payload: jsonEncode(params));
      var res = json.decode(data!);
      var status = (res["status"] as int);
      if (status == 0) {
        return res["data"];
      } else {
        throw Exception(res["message"]);
      }
    } catch (e) {
      var error = "$e".split("codeName: ")[1].split(",")[0];
      if (error == "UNAUTHENTICATED" ||
          error == "UNAVAILABLE" ||
          error == "NOT_FOUND" ||
          error == "INTERNAL") {
        error = "error_${error.toLowerCase()}";
      } else {
        error = "RPC: $id Error: $e";
      }
      throw SkeletonException(StatusCode.C503_SERVICE_UNAVAILABLE.value, error);
    }
  }

  Future<dynamic> httpRPC(String id, {Map? params}) async {
    params = params ?? {};
    http.Response? response;
    try {
      var json = jsonEncode(params);
      final url = Uri.parse("${configs["host"]}/$id");
      log("${url.toString()} $json");
      response = await http.post(url, headers: {}, body: params);
    } catch (e) {
      var error = "$e";
      if (_isDisconnected(error)) {
        throw SkeletonException(
            StatusCode.C503_SERVICE_UNAVAILABLE.value, error);
      }
    }
    final status = response!.statusCode;
    if (status != 200) {
      throw SkeletonException(status.toStatus().value,
          response.body.isNotEmpty ? response.body : "error_$status".l());
    }

    log(response.body);
    var responseData = jsonDecode(response.body);
    if (!responseData["status"]) {
      // var statusCode = (responseData["data"]["code"] as int).toStatus();
      throw SkeletonException(-1, responseData["data"]);
    }
    return responseData["data"];
  }

  bool _isDisconnected(String error) {
    return error.contains("No host specified in URI") ||
        error.contains("Connection refused") ||
        error.contains("Failed host lookup");
  }

  /* 
  Future<List<PublicAccount>> getAccounts(List userIds) async {
    if (userIds.isEmpty) {
      return [];
    }
    var data = await _nakamaClient.rpc(
        session: _session!,
        id: RpcId.accountsGet.name,
        payload: userIds.join(','));
    var accounts = <PublicAccount>[];
    var list = data!.split('|');
    for (var item in list) {
      accounts.add(PublicAccount.fromMap(json.decode(item)));
    }
    return accounts;
  }
  Future<Result> getOrders() async {
    var result = await rpc(RpcId.orderGet);
    if (!result.response.isSuccess()) return result;
    rules.orders.clear();
    for (var orderData in result.data) {
      var order = Order.fromData(orderData);
      rules.orders[order.id] = order;
    }
    return Result(Responses.success, "", rules.orders);
  }
   */

  static const rpcContentCategories = "content_categories";
  static const rpcContentContents = "content_contents";
  // {"groupId":"essential_introducing_en", "nativeLanguage":"en", "targetLanguage":"tr"}
}
