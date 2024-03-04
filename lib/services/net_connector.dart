import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:nakama/nakama.dart';

import '../../app_export.dart';

class LoadingData {
  static String baseURL = "";
  static String chatIp = "";
  static int chatPort = 0;
  Map configs = {};
  Contents? contents;
}

class NetConnector extends IService {
  static const rpcDialogue = "dialogue.php";

  LoadingData loadingData = LoadingData();
  NakamaGrpcClient? _nakamaClient;
  Session? _session;
  Account? account;

  @override
  initialize({List<Object>? args}) async {
    var version = int.parse(DeviceInfo.buildNumber);
    await _loadConfigs(version);

    if (Pref.targetLanguage.getString().isNotEmpty) {
    _session = await connect();

      // Load Contents
      var data = await rpc(rpcContentCategories);
      loadingData.contents = Contents.initialize(data);

    // // Check internal version, public users avoidance
    // var test = _config["updates"]["test"];
    // if (test["version"] < version) {
    //   if (!test["testers"].contains(loadData.account.id)) {
    //     throw SkeletonException(StatusCode.C702_UPDATE_TEST.value, "");
    //   }
    // }
    }
    super.initialize();
  }

  _loadConfigs(int version) async {
    http.Response? response;
    try {
      response = await http.get(
          Uri.parse('https://8ball.turnedondigital.com/lingai/configs.json'));
    } catch (e) {
      var error = '$e';
      if (_isDisconnected(error)) {
        throw SkeletonException(
            StatusCode.C503_SERVICE_UNAVAILABLE.value, error);
      }
    }
    if (response!.statusCode == 200) {
      loadingData.configs = json.decode(response.body);
      var updates = loadingData.configs["updates"];
      if (updates["force"]["version"] > version) {
        throw SkeletonException(
            StatusCode.C701_UPDATE_FORCE.value, updates["force"]["message"]);
      } else if (!Pref.skipUpdate.getBool() &&
          updates["notice"]["version"] > version) {
        throw SkeletonException(
            StatusCode.C700_UPDATE_NOTICE.value, updates["notice"]["message"]);
      }
      Pref.skipUpdate.setBool(false);
      LoadingData.baseURL = loadingData.configs["host"];
      LoaderWidget.baseURL = loadingData.configs['assetsServer']!;
      LoaderWidget.hashMap = Map.castFrom(loadingData.configs['files']);
      log("Config loaded.");
    } else {
      throw SkeletonException(
          StatusCode.C999_UNKNOWN_ERROR.value, 'Failed to load config file');
    }
  }

  // Connect to nakama server
  Future<Session> connect() async {
    _nakamaClient = NakamaGrpcClient(
        host: '192.168.1.133' /* loadingData.configs['host'] */,
        port: loadingData.configs['port'],
        serverKey: 'defaultkey',
        ssl: false);

    var timezone = DateTime.now().timeZoneOffset.inSeconds;
    var location = await FlutterTimezone.getLocalTimezone();
    var store = "GooglePlay";
    var data = {
      "timezone": "$timezone",
      "location": location,
      "store": store,
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
      var error = '$e'.split('codeName: ')[1].split(",")[0];
      if (error == "UNAUTHENTICATED" ||
          error == "UNAVAILABLE" ||
          error == "NOT_FOUND" ||
          error == "INTERNAL") {
        error = 'error_${error.toLowerCase()}';
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
      final url = Uri.parse('${LoadingData.baseURL}/$id');
      log("${url.toString()} $json");
      response = await http.post(url, headers: {}, body: params);
    } catch (e) {
      var error = '$e';
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
    if (!responseData['status']) {
      // var statusCode = (responseData['data']['code'] as int).toStatus();
      throw SkeletonException(-1, responseData['data']);
    }
    return responseData['data'];
  }

  bool _isDisconnected(String error) {
    return error.contains("No host specified in URI") ||
        error.contains("Connection refused") ||
        error.contains("Failed host lookup");
  }
}
