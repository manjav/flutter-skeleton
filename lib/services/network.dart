import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/core/iservices.dart';
import 'core/infra.dart';

abstract class INetwork extends IService {
  Future<Result<T>> rpc<T>(RpcId id, {String? payload});
  final response = NetResponse();
  @protected
  void updateResponse(LoadingState state, String message);

//TODO added by hamid
  Future<Response> loadData();
}

class Network extends INetwork {
  Network();
  var baseURL = "https://fc.turnedondigital.com/";

  dynamic config;
  var messages = <Message>[];

  final _serverLessMode = false;
  final _localHost = ''; //'192.168.1.101';
  final _rpcTimes = <RpcId, int>{};

//TODO added by hamid
  @override
  loadData() async {
    await Future.delayed(const Duration(seconds: 1));

    return Response(statusCode: 200, data: {
      "name": "Hamiiid testi",
      "gold": 2000,
      "nectar": 1800,
      "positionInTribe": 265,
      "rank": 623,
      "level": 25,
      "cards": [
        {
          "imageUrl": "assets/images/fruits/o1.png",
          "title": "orange1",
          "level": 1,
          "stamina": 2
        },
        {
          "imageUrl": "assets/images/fruits/o2.png",
          "title": "orange2",
          "level": 2,
          "stamina": 6
        },
        {
          "imageUrl": "assets/images/fruits/c1.png",
          "title": "Carrot1",
          "level": 3,
          "stamina": 15
        },
        {
          "imageUrl": "assets/images/fruits/c2.png",
          "title": "Carrot2",
          "level": 4,
          "stamina": 30
        },
        {
          "imageUrl": "assets/images/fruits/c2.png",
          "title": "Carrot2",
          "level": 4,
          "stamina": 30
        },
        {
          "imageUrl": "assets/images/fruits/c2.png",
          "title": "Carrot2",
          "level": 4,
          "stamina": 30
        },
        {
          "imageUrl": "assets/images/fruits/c2.png",
          "title": "Carrot2",
          "level": 4,
          "stamina": 30
        },
        {
          "imageUrl": "assets/images/fruits/c2.png",
          "title": "Carrot2",
          "level": 4,
          "stamina": 30
        }
      ]
    });
  }

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
    if (_serverLessMode) {
      var configJson =
          '{"server":{"host":"$_localHost","port":4349},"files":{}}';
      config = json.decode(configJson);
    } else {
      if (config != null) return;
      try {
        final response = await http.get(Uri.parse('${baseURL}configs.json'));
        if (response.statusCode == 200) {
          config = json.decode(response.body);
          if (_localHost.isNotEmpty) {
            config['server']['host'] = _localHost;
          }
        } else {
          throw Exception('Failed to load config file');
        }
      } catch (e) {
        updateResponse(LoadingState.disconnect, e.toString());
      }
    }
  }

  // Connect to server
  _connection() async {
    await Future.delayed(const Duration(seconds: 1));
    updateResponse(LoadingState.connect, "connected.");
  }

  @override
  Future<Result<T>> rpc<T>(RpcId id, {String? payload}) async {
    var now = DateTime.now().millisecondsSinceEpoch;
    var diff = (now - (_rpcTimes[id] ?? 0));
    if (diff < 100 && response.state == LoadingState.complete) {
      return Result(Responses.alreadyExists, "Duplicate RPC call.", null);
    }
    _rpcTimes[id] = now;

    try {
      var rpc = await http.get(Uri.parse("uri"));
      var res = json.decode(rpc.body);
      var response = (res['response'] as int).toResponse();
      return Result<T>(response, res['message'], res['data']);
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

enum RpcId { battle }

extension RpcIdEx on RpcId {
  String get name {
    switch (this) {
      case RpcId.battle:
        return "battle";
      default:
        return "default_id";
    }
  }
}

//TODO added by hamid
class Response<T> {
  final int _statusCode;
  final Map<String, T> _data;

  Response({required int statusCode, required Map<String, T> data})
      : _statusCode = statusCode,
        _data = data;

  get getStatusCode => _statusCode;
  get getData => _data;
}
