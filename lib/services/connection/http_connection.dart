// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/localization.dart';
import '../../utils/utils.dart';
import '../deviceinfo.dart';
import '../iservices.dart';

abstract class IConnection extends IService {
  final response = NetResponse();

  @protected
  Future<void> loadConfigs();

  @protected
  Future<Result<String>> loadAccount();

  @protected
  void updateResponse(LoadingState state, String message);

  Future<Result<T>> rpc<T>(RpcId id, {Map<String, dynamic>? params});
}

enum LoadParams {
  udid,
  device_name,
  game_version,
  os_type,
  os_version,
  model,
  store_type,
  name
}

class HttpConnection extends IConnection {
  HttpConnection();

  Map cookies = {};

  @override
  initialize({List<Object>? args}) async {
    await loadConfigs();
    var playerData = await loadAccount();
    updateResponse(LoadingState.connect, "Account ${'user'} connected.");
    super.initialize();
    return playerData;
  }

  // Load the Config file
  @override
  loadConfigs() async {
    //  log("Config loaded.");
  }

  // Connect to server
  @override
  Future<Result<String>> loadAccount() async {
    var params = <String, dynamic>{
      LoadParams.udid.name: DeviceInfo.adId,
      LoadParams.device_name.name: DeviceInfo.model,
      LoadParams.game_version.name: 'app_version'.l(),
      LoadParams.os_type.name: 1,
      LoadParams.os_version.name: DeviceInfo.osVersion,
      LoadParams.model.name: DeviceInfo.model,
      LoadParams.store_type.name: "bazar",
      LoadParams.name.name: "Mansour"
    };
    var playerData = await rpc<String>(RpcId.playerLoad, params: params);
    updateResponse(LoadingState.connect, "connected.");
    return playerData;
  }

  @override
  Future<Result<T>> rpc<T>(RpcId id, {Map? params}) async {
    try {
      final headers = getDefaultHeader();
      var data = {};
      if (params != null) {
        // var json = '{"game_version":"2","device_name":"Ali MacBook P6ro","os_version":"13.0.0","model":"KFJWI","udid":"e6ac281eae92abd4581116b380da33a8","store_type":"parsian","restore_key":"apple1sys","os_type":2}';
        var json = jsonEncode(params);
        log(json);
        data = {'edata': json.xorEncrypt()};
        log(json.xorEncrypt());
      }
      final url = Uri.parse(
          '${"server_protocol".l()}://${"server_host".l()}/${id.value}');
      final response = await http.post(url, headers: headers, body: data);
      final status = response.statusCode;
      if (status != 200) {
        throw Exception('http.post error: statusCode= $status');
      }
      log(response.body);
      var body = response.body.xorDecrypt();
      log(body);

      // var res = json.decode(rpc.body);
      // var response = (res['response'] as int).toResponse();
      // return Result<T>(response, res['message'], res['data']);
      return Result<T>(Responses.notEnough, '', body as T);
    } catch (e) {
      var error = '$e'.split('codeName: ')[1].split(",")[0];
      if (error == "UNAUTHENTICATED" ||
          error == "UNAVAILABLE" ||
          error == "NOT_FOUND" ||
          error == "INTERNAL") {
        error = 'error_${error.toLowerCase()}';
      } else {
        error = "RPC: ${id.name} Error: $e";
      }
      updateResponse(LoadingState.error, error);
      return Result(Responses.unknown, "error", null);
    }
  }

  @override
  void updateResponse(LoadingState state, String message) {
    response.state = state;
    response.message = message;
    log("update response => ${state.name} - $message");
  }

  Map<String, String>? getDefaultHeader(
      {Map<String, String>? headers, bool showLogs = true}) {
    if (!Platform.isAndroid && !Platform.isWindows /*&& buildType!="debug"*/) {
      return null;
    }
    if (showLogs) log("getting default headers");
    headers = headers ?? {};

    // if (!cookiesLoaded) {
    //     loadCookies();
    //  }

    headers["Content-Type"] = "application/x-www-form-urlencoded";
    for (var entry in cookies.entries) {
      if (headers["Cookie"] == null) {
        headers["Cookie"] = "";
      }
      headers["Cookie"] = "${headers["Cookie"]} ${entry.key}=${entry.value}; ";
    }

    return headers;
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

enum RpcId { battle, playerLoad }

extension RpcIdEx on RpcId {
  String get value {
    return switch (this) {
      RpcId.battle => "battle",
      RpcId.playerLoad => "player/load",
    };
  }
}
