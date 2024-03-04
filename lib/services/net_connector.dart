import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app_export.dart';

class LoadingData {
  static String baseURL = "";
  static String chatIp = "";
  static int chatPort = 0;
}

class NetConnector extends IService {
  static const rpcDialogue = "dialogue.php";

  LoadingData loadData = LoadingData();
  Map<String, dynamic> _config = {};
  NakamaGrpcClient? _nakamaClient;
  Session? _session;
  Account? account;

  @override
  initialize({List<Object>? args}) async {
    var version = int.parse(DeviceInfo.buildNumber);
    await _loadConfigs(version);
    _session = await connect();


    // var loader = Loader();
    // await loader.load(
    //     "data.json.zip", "${LoaderWidget.baseURL}/texts/data.json.zip",
    //     hash: LoaderWidget.hashMap["data.json"]);
    // var jsonData = utf8.decode(loader.bytes!);
    // loadData.init(jsonDecode(jsonData));

    // // Load account data
    // var params = <String, dynamic>{
    //   RpcParams.os_type.name: 2,
    //   RpcParams.udid.name: DeviceInfo.adId,
    //   RpcParams.model.name: DeviceInfo.model,
    //   RpcParams.device_name.name: DeviceInfo.model,
    //   RpcParams.game_version.name: version,
    //   RpcParams.os_version.name: DeviceInfo.osVersion,
    //   RpcParams.store_type.name: "google",
    // };
    // if (Pref.restoreKey.getString().isNotEmpty) {
    //   params[RpcParams.restore_key.name] = Pref.restoreKey.getString();
    // }
    // var data = await rpc(RpcId.playerLoad, params: params);
    // loadData.account = Account.initialize(data, loadData);

    // // Check internal version, public users avoidance
    // var test = _config["updates"]["test"];
    // if (test["version"] < version) {
    //   if (!test["testers"].contains(loadData.account.id)) {
    //     throw SkeletonException(StatusCode.C702_UPDATE_TEST.value, "");
    //   }
    // }
    // Pref.restoreKey.setString(loadData.account.restoreKey);
    super.initialize();
    // return loadData;
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
      _config = json.decode(response.body);
      var updates = _config["updates"];
      if (updates["force"]["version"] > version) {
        throw SkeletonException(
            StatusCode.C701_UPDATE_FORCE.value, updates["force"]["message"]);
      } else if (!Pref.skipUpdate.getBool() &&
          updates["notice"]["version"] > version) {
        throw SkeletonException(
            StatusCode.C700_UPDATE_NOTICE.value, updates["notice"]["message"]);
      }
      Pref.skipUpdate.setBool(false);
      LoadingData.baseURL = _config["host"];
      LoaderWidget.baseURL = _config['assetsServer'];
      LoaderWidget.hashMap = Map.castFrom(_config['files']);
      log("Config loaded.");
    } else {
      throw SkeletonException(
          StatusCode.C999_UNKNOWN_ERROR.value, 'Failed to load config file');
    }
  }

  // Connect to nakama server
  Future<Session> connect() async {
    _nakamaClient = NakamaGrpcClient(
        host: '192.168.1.133' /* _config['host'] */,
        port: _config['port'],
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
      result = await rpc(id, params: params);
    } on SkeletonException catch (e) {
      if (context.mounted) {
        await serviceLocator<RouteService>().to(Routes.popupMessage,
            args: {"title": "Error", "message": "error_${e.statusCode}".l()});
      }
      rethrow;
    }
    return result as T;
  }

  Future<dynamic> rpc(String id, {Map? params}) async {
    params = params ?? {};
    http.Response? response;
    try {
      final headers = _getDefaultHeader();

      // var data = {};
      var json = jsonEncode(params);
      // data = params;
      final url = Uri.parse('${LoadingData.baseURL}/$id');
      log("${url.toString()} $json");
      // if (id.requestType == HttpRequestType.get) {
      // response = await http.get(url, headers: headers, params: params);
      // } else {
      response = await http.post(url, headers: headers, body: params);
      // }
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

    _proccessResponseHeaders(response.headers);
    log(response.body);
    var responseData = jsonDecode(response.body);
    if (!responseData['status']) {
      // var statusCode = (responseData['data']['code'] as int).toStatus();
      throw SkeletonException(-1, responseData['data']);
    }
    return responseData['data'];
  }

  void _proccessResponseHeaders(Map<String, String> header) {
    if (header.containsKey('set-cookie')) {
      Pref.cookies.setString(header["set-cookie"]!);
    }
  }

  Map<String, String>? _getDefaultHeader({Map<String, String>? headers}) {
    if (!Platform.isAndroid && !Platform.isWindows /*&& buildType!="debug"*/) {
      return null;
    }
    headers = headers ?? {};

    headers["Content-Type"] = "application/x-www-form-urlencoded";
    // headers["Host"] = _config["host"];
    var cookies = Pref.cookies.getString();
    if (cookies.isNotEmpty) {
      headers["Cookie"] = cookies;
    }
    return headers;
  }

  bool _isDisconnected(String error) {
    return error.contains("No host specified in URI") ||
        error.contains("Connection refused") ||
        error.contains("Failed host lookup");
  }
}
