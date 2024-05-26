import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../app_export.dart';

class HttpConnection extends IService {
  LoadingData loadData = LoadingData();
  Map<String, dynamic> _config = {};

  @override
  initialize({List<Object>? args}) async {
    var version = int.parse(DeviceInfo.buildNumber);
    await _loadConfigs(version);

    var loader = Loader();
    await loader.load(
        "data.json.zip", "${LoaderWidget.baseURL}/texts/data.json.zip",
        hash: LoaderWidget.hashMap["data.json"]);
    var jsonData = utf8.decode(loader.bytes!);
    loadData.init(jsonDecode(jsonData));

    // Load account data
    var params = <String, dynamic>{
      RpcParams.os_type.name: 2,
      RpcParams.udid.name: DeviceInfo.adId,
      RpcParams.model.name: DeviceInfo.model,
      RpcParams.device_name.name: DeviceInfo.model,
      RpcParams.game_version.name: version,
      RpcParams.os_version.name: DeviceInfo.osVersion,
      RpcParams.store_type.name: "google",
    };
    if (Pref.restoreKey.getString().isNotEmpty) {
      params[RpcParams.restore_key.name] = Pref.restoreKey.getString();
    }
    var data = await rpc(RpcId.playerLoad, params: params);
    loadData.account = Account.initialize(data, loadData);

    // Check internal version, public users avoidance
    // var test = _config["updates"]["test"];
    // if (test["version"] < version) {
    //   if (!test["testers"].contains(loadData.account.id)) {
    //     throw SkeletonException(StatusCode.C702_UPDATE_TEST.value, "");
    //   }
    // }
    Pref.restoreKey.setString(loadData.account.restoreKey);
    super.initialize();
    return loadData;
  }

  _loadConfigs(int version) async {
    http.Response? response;
    try {
      response = await http
          .get(Uri.parse('https://8ball.turnedondigital.com/fc/configs.json'));
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
      LoadingData.baseURL = "http://${_config['ip']}";
      LoadingData.chatIp = _config['chatIp'];
      LoadingData.chatPort = _config['chatPort'];
      LoaderWidget.baseURL = _config['assetsServer'];
      LoaderWidget.hashMap = Map.castFrom(_config['files']);
      log("Config loaded.");
    } else {
      throw SkeletonException(
          StatusCode.C100_UNEXPECTED_ERROR.value, 'Failed to load config file');
    }
  }

  Future<T> tryRpc<T>(BuildContext context, RpcId id,
      {Map? params, showError = true}) async {
    dynamic result;
    try {
      result = await rpc(id, params: params);
    } on SkeletonException catch (e) {
      if (context.mounted && showError) {
        await serviceLocator<RouteService>().to(
          Routes.popupMessage,
          args: {"title": "error".l(), "message": "error_${e.statusCode}".l()},
        );
      }
      rethrow;
    }
    return result as T;
  }

  Future<dynamic> rpc(RpcId id, {Map? params}) async {
    params = params ?? {};
    http.Response? response;
    try {
      final headers = _getDefaultHeader();
      var data = {};
      // var json =
      //     '{"game_version":"","device_name":"Ali MacBook Pro","os_version":"13.0.0","model":"KFJWI","udid":"e6ac281eae92abd4581116b380da33a8","store_type":"parsian","os_type":2}';
      var json = jsonEncode(params);
      data = id.needsEncryption ? {'edata': json.xorEncrypt()} : params;
      final url = Uri.parse('${LoadingData.baseURL}/${id.value}');
      log("${url.toString()} $json");
      if (id.requestType == HttpRequestType.get) {
        response = await http.get(url, headers: headers);
      } else {
        response = await http.post(url, headers: headers, body: data);
      }
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
    // log(response.body);
    var body = id.needsEncryption ? response.body.xorDecrypt() : response.body;
    // log(body);

    var responseData = jsonDecode(body);
    if (!responseData['status']) {
      var statusCode = (responseData['data']['code'] as int).toStatus();
      throw SkeletonException(statusCode.value, response.body);
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
    headers["Host"] = _config["host"];
    var cookies = Pref.cookies.getString();
    // for (var entry in cookies.entries) {
    //   if (headers["Cookie"] == null) {
    //     headers["Cookie"] = "";
    //   }
    //   headers["Cookie"] = "${headers["Cookie"]} ${entry.key}=${entry.value}; ";
    // }
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

enum LoadingState { loading, disconnect, connect, complete, error }

class NetResponse {
  var state = LoadingState.loading;
  var message = "";

  @override
  String toString() {
    return '[state:$state, message:$message]';
  }
}
