import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nakama/nakama.dart';
import 'package:grpc/grpc.dart' as grpc;

import '../../app_export.dart';

class NetConnector extends IService {
  Session? _session;
  NakamaGrpcClient? _nakamaClient;
  Type typeOf<T>() => T;
  final Map<String, DateTime> _rpcTimes = {};
  static Map<String, dynamic> configs = {};

  @override
  initialize({List<Object>? args}) async {
    var version = int.parse(DeviceInfo.buildNumber);
    await _loadConfigs(version);

    _session = await connect();
    var account = await getAccount();
    Pref.username.setString(account.user.id);
    log(jsonEncode(account.user));

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
          Uri.parse("https://8ball.turnedondigital.com/lifetalk/configs.json"));
    } catch (e) {
      var error = "$e";
      if (_isDisconnected(error)) {
        throw SkeletonException(StatusCode.UNAVAILABLE, error);
      }
    }
    if (response!.statusCode == 200) {
      configs = json.decode(response.body);

      // Initial versions
      final versionsMap = configs["versions"] ?? {};
      final Map<int, VersionConfigs> versions = {};
      int latestVersion = 0;
      for (var entry in versionsMap.entries) {
        final key = int.parse(entry.key);
        if (latestVersion < key) {
          latestVersion = key;
        }
        versions[key] = VersionConfigs(
          key,
          entry.value["port"] ?? configs["port"],
          entry.value["host"] ?? configs["host"],
          entry.value["assetsUrl"] ?? configs["assetsUrl"],
          entry.value["changelog"] ?? "",
          entry.value["nativeLanguage"] ?? configs["nativeLanguage"],
          entry.value["targetLanguage"] ?? configs["targetLanguage"],
          VersionPriority.values[entry.value["priority"] ?? 2],
        );
        // Update connection according to version
        if (version == key) {
          configs["port"] = versions[key]!.port;
          configs["host"] = versions[key]!.host;
          configs["assetsUrl"] = versions[key]!.assetsUrl;
          configs["nativeLanguage"] = versions[key]!.nativeLanguage;
          configs["targetLanguage"] = versions[key]!.targetLanguage;
        }
      }

      // Update warns
      final latestConfig = versions[latestVersion]!;
      if (latestConfig.version > version) {
        if (latestConfig.priority == VersionPriority.force) {
          throw SkeletonException(
              StatusCode.UPDATE_FORCE, latestConfig.changelog);
        } else if (Pref.updatePassed.getInt(defaultValue: 0) !=
                latestConfig.version &&
            latestConfig.priority == VersionPriority.notice) {
          Pref.updatePassed.setInt(latestConfig.version);
          throw SkeletonException(
              StatusCode.UPDATE_NOTICE, latestConfig.changelog);
        }
      }

      LoaderWidget.baseURL = configs["assetsUrl"]!;
      LoaderWidget.hashMap = Map.castFrom(configs["files"]);
      Localization.languageCode = configs["nativeLanguage"];
      Localization.targetLanguage = configs["targetLanguage"];
      log("Config loaded.");
    } else {
      throw SkeletonException(
          StatusCode.UNKNOWN_ERROR, "Failed to load config file");
    }
  }

  // Connect to nakama server
  Future<Session> connect() async {
    _nakamaClient = NakamaGrpcClient(
        host: /* "192.168.1.133",// */ configs["host"],
        port: /* 3359, // */ configs["port"],
        serverKey: "defaultkey",
        ssl: false);

    final timezone = DateTime.now().timeZoneOffset.inSeconds;
    final location = await FlutterTimezone.getLocalTimezone();
    const store = "GooglePlay";
    final data = {
      "store": store,
      "location": location,
      "timezone": "$timezone",
      "latestVersion": DeviceInfo.buildNumber,
      "displayName":
          "u_${DeviceInfo.model}_${location.split("/")[1]}_${StringExtensions.getRandomString(2)}",
      "device":
          '{"model":"${DeviceInfo.model}", "osVersion":"${DeviceInfo.osVersion}", "baseVersion":"${DeviceInfo.baseVersion}"}'
    };

    try {
      var session = await _nakamaClient!
          .authenticateDevice(deviceId: DeviceInfo.adId, vars: data);
      return session;
    } catch (e) {
      log(e.toString());
      throw SkeletonException(StatusCode.UNKNOWN_ERROR, "Lost Connection!");
    }
  }

  Future<Account> getAccount() async {
    return await _nakamaClient!.getAccount(_session!);
  }

  Future<void> sessionRefresh() async {
    _session = await connect();
  }

  Future<T> tryRpc<T>(BuildContext context, String id, {Map? params}) async {
    dynamic result;
    try {
      result = await rpc<T>(id, params: params);
    } on SkeletonException catch (e) {
      if (context.mounted) {
        await Get.toNamed(Routes.popupMessage, arguments: {
          "title": e.message,
          "message": "error_${e.statusCode}".l()
        });
      }
      rethrow;
    }
    return result;
  }

  Future<T> rpc<T>(String id, {Map? params}) async {
    /// Frequent RPC avoidance
    final now = DateTime.now();
    final diff = now.difference(_rpcTimes[id] ?? DateTime(1)).inMilliseconds;
    // print("1 $diff $id ${_session!.expiresAt}");
    if (diff > 0 && diff < 1500) {
      log("Frequent RPC $id");
      Type type = typeOf<T>();
      if (type.toString() == "List<dynamic>") return [] as T;
      if (type.toString() == "Map<dynamic, dynamic>") return {} as T;
      return null as T;
    }
    params ??= {};

    try {
      var data = await _nakamaClient!
          .rpc(session: _session!, id: id, payload: jsonEncode(params));
      var result = json.decode(data!);
      var status = (result["status"] as int).toStatus();
      if (status == StatusCode.SUCCESS) {
        _rpcTimes[id] = now;
        return result["data"];
      } else {
        throw SkeletonException(status, result["message"]);
      }
    } on grpc.GrpcError catch (e) {
      final code = e.code.toStatus();
      var diff = now.difference(_rpcTimes[id] ?? DateTime(1)).inMilliseconds;
      if (code == StatusCode.UNAUTHENTICATED && diff > 0) {
        // print("2 $diff $id ${_session!.expiresAt}");
        _rpcTimes[id] = DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch + 10000);
        await sessionRefresh();
        await Future.delayed(Duration(seconds: 1));
        return await rpc(id, params: params);
      } else {
        throw SkeletonException(code, e.message ?? "", e.rawResponse);
      }
    } catch (e) {
      throw SkeletonException(StatusCode.UNKNOWN_ERROR, e.toString());
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
        throw SkeletonException(StatusCode.UNAVAILABLE, error);
      }
    }
    final status = response!.statusCode;
    if (status != 200) {
      throw SkeletonException(status.toStatus(),
          response.body.isNotEmpty ? response.body : "error_$status".l());
    }

    log(response.body);
    var responseData = jsonDecode(response.body);
    if (!responseData["status"]) {
      throw SkeletonException(StatusCode.UNKNOWN_ERROR, responseData["data"]);
    }
    return responseData["data"];
  }

  bool _isDisconnected(String error) {
    return error.contains("No host specified in URI") ||
        error.contains("Connection refused") ||
        error.contains("Failed host lookup");
  }

  Future<Map<String, Map<String, dynamic>>> readStorage(
    String collectionId, {
    String? userId,
    int limit = 100,
  }) async {
    final objects = await _nakamaClient!.listStorageObjects(
      userId: userId,
      limit: limit,
      session: _session!,
      collection: collectionId,
    );
    var data = <String, Map<String, dynamic>>{};
    for (var object in objects.objects) {
      data[object.key] = jsonDecode(object.value);
    }
    return data;
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
}

class VersionConfigs {
  final int port;
  final int version;
  final String host;
  final String assetsUrl;
  final String changelog;
  final String nativeLanguage;
  final String targetLanguage;
  final VersionPriority priority;

  VersionConfigs(
    this.version,
    this.port,
    this.host,
    this.assetsUrl,
    this.changelog,
    this.nativeLanguage,
    this.targetLanguage,
    this.priority,
  );
}

enum VersionPriority { alpha, beta, normal, notice, force }
