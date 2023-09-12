import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/core/account.dart';
import '../../data/core/result.dart';
import '../../data/core/rpc.dart';
import '../../data/core/rpc_data.dart';
import '../../services/localization.dart';
import '../../services/prefs.dart';
import '../../utils/loader.dart';
import '../../utils/utils.dart';
import '../../view/route_provider.dart';
import '../../view/widgets/loaderwidget.dart';
import '../deviceinfo.dart';
import '../iservices.dart';

class HttpConnection extends IService {
  LoadingData loadData = LoadingData();
  Map<String, dynamic> _config = {};

  @override
  initialize({List<Object>? args}) async {
    await _loadConfigs();

    var loader = Loader();
    await loader.load(
        "data.json.zip", "${LoaderWidget.baseURL}/texts/data.json.zip",
        hash: LoaderWidget.hashMap["data.json"]);
    var jsonData = utf8.decode(loader.bytes!);
    loadData.init(jsonDecode(jsonData));

    // Load account data
    var params = <String, dynamic>{
      RpcParams.udid.name: DeviceInfo.adId,
      RpcParams.device_name.name: DeviceInfo.model,
      RpcParams.game_version.name: 'app_version'.l(),
      RpcParams.os_type.name: 2,
      RpcParams.os_version.name: DeviceInfo.osVersion,
      RpcParams.model.name: DeviceInfo.model,
      RpcParams.store_type.name: "google",
      // RpcParams.restore_key.name: "hello69582879",
    };
    if (Pref.restoreKey.getString().isNotEmpty) {
      params[RpcParams.restore_key.name] = Pref.restoreKey.getString();
    }
    var data = await rpc(RpcId.playerLoad, params: params);
    loadData.account = Account()..init(data, args: loadData);
    super.initialize();
    return loadData;
  }

  _loadConfigs() async {
    http.Response? response;
    try {
      response = await http
          .get(Uri.parse('https://8ball.turnedondigital.com/fc/configs.json'));
    } catch (e) {
      var error = '$e';
      if (_isDisconnected(error)) {
        throw RpcException(StatusCode.C503_SERVICE_UNAVAILABLE, error);
      }
    }
    if (response!.statusCode == 200) {
      _config = json.decode(response.body);
      LoadingData.baseURL = "http://${_config['ip']}";
      LoadingData.chatIp = _config['chatIp'];
      LoadingData.chatPort = _config['chatPort'];
      LoaderWidget.baseURL = _config['assetsServer'];
      LoaderWidget.hashMap = Map.castFrom(_config['files']);
      log("Config loaded.");
    } else {
      throw RpcException(
          StatusCode.C100_UNEXPECTED_ERROR, 'Failed to load config file');
    }
  }

  Future<T> tryRpc<T>(BuildContext context, RpcId id, {Map? params}) async {
    dynamic result;
    try {
      result = await rpc(id, params: params);
    } on RpcException catch (e) {
      if (context.mounted) {
      Navigator.pushNamed(context, Routes.popupMessage.routeName, arguments: {
        "title": "Error",
        "message": "error_${e.statusCode.value}".l()
      });
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
        throw RpcException(StatusCode.C503_SERVICE_UNAVAILABLE, error);
      }
    }
    final status = response!.statusCode;
    if (status != 200) {
      throw RpcException(status.toStatus(),
          response.body.isNotEmpty ? response.body : "error_$status".l());
    }

    _proccessResponseHeaders(response.headers);
    // log(response.body);
    var body = id.needsEncryption ? response.body.xorDecrypt() : response.body;
    // log(body);

    var responseData = jsonDecode(body);
    if (!responseData['status']) {
      var statusCode = (responseData['data']['code'] as int).toStatus();
      throw RpcException(statusCode, response.body);
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
