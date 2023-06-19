import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/iservices.dart';
import '../core/infra.dart';

abstract class IConnection extends IService {
  Future<Result<T>> rpc<T>(RpcId id, {Map<String, dynamic>? params});
  final response = NetResponse();
  @protected
  void updateResponse(LoadingState state, String message);
}

class HttpConnection extends IConnection {
  HttpConnection();
  var baseURL = "https://fc.turnedondigital.com/";

  dynamic config;
  var messages = <Message>[];

  @override
  initialize({List<Object>? args}) async {
    await _loadConfig();
    log("Config loaded.");
    await _connection();
    log("Nakama connected.");

    // Load account
    log("Account data loaded.");

    updateResponse(LoadingState.connect, "Account ${'user'} connected.");
    super.initialize();
  }

  // Load the Config file
  _loadConfig() async {
    //  log("Config loaded.");
  }

  // Connect to server
  _connection() async {
    await Future.delayed(const Duration(seconds: 1));
    updateResponse(LoadingState.connect, "connected.");
  }

  @override
  Future<Result<T>> rpc<T>(RpcId id, {Map? params}) async {
    try {
      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
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
      return Result(Responses.unknown, error, null);
    }
  }

  @override
  void updateResponse(LoadingState state, String message) {
    response.state = state;
    response.message = message;
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
  String get name {
    return switch (this) {
      RpcId.battle => "battle",
      _ => "default_id",
    };
  }
}
