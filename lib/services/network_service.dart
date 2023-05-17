import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'core/infra.dart';

abstract class NetworkService {
  // Future<NetConnection> initialize();
  connect();
  Future<Result<T>> rpc<T>(RpcId id, {String? payload});
}
// ignore_for_file: implementation_imports, depend_on_referenced_packages

class Network implements NetworkService {
  Network(
      // super.services
      );
  var baseURL = "https://alchemy.turnedondigital.com/looterkings/";

  dynamic config;
  var messages = <Message>[];

  final _serverLessMode = false;
  final _localHost = ''; //'192.168.1.101';
  final _stagingMode = false;
  final _rpcTimes = <RpcId, int>{};

  var response = NetResponse();

  @override
  connect() async {
    // await _konvert();

    await _loadConfig();
    log("Config loaded.");
    await _connection();
    log("Nakama connected.");

    // Load account
    await refreshAccount();
    log("Account data loaded.");

    // Load the resources data

    /// TODO:  hamiiid
    // var resources = await rpc<List>(RpcId.resourceData);

    // Load the rules data
    // rules.wallet.init(json.decode(account.wallet));// TODO:  Hamiiid - because of the rules class this line commented

    // if (rules.wallet['_explore'] < 1) {
    //   TutorSteps.welcome.commit(true);
    // } else if (rules.wallet['_merge'] < 1) {
    //   TutorSteps.exploreFirst.commit(true);
    // } else if (rules.wallet['_order'] > 0) {
    // TutorSteps.fine.commit();
    // }

    // TODO:  hamiiid
    // var rulesResult = await rpc(RpcId.rulesGet);

    // TODO:  Hamiiid - because of the rules class this line commented
    // rules.load(rulesResult.data, resources);

    log("Orders updated.");

    await updateMessages();
    log("Messages updated.");

    updateResponse(LoadingState.connect, "Account ${'user'} connected.");
  }

  // Load the Configs
  _loadConfig() async {
    if (_serverLessMode) {
      var configJson =
          '{"server":{"host":"$_localHost","port":4349},"files":{}}';
      config = json.decode(configJson);
    } else {
      if (config != null) return;
      try {
        var configName = _stagingMode ? "configs-staging" : "configs";
        final response = await http.get(Uri.parse('$baseURL$configName.json'));
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

  // Connect to nakama server
  _connection() async {
    // try {
    //   _session = await _nakamaClient.authenticateDevice(
    //       deviceId: Device.adId, vars: data);
    // } catch (e) {
    //   updateResponse(LoadingState.disconnect, e.toString());
    // }
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
  updateResponse(LoadingState state, String message) {
    response.state = state;
    response.message = message;
    // notifyListeners();
  }

  @override
  log(log) {
    debugPrint(log);
  }

  @override
  exchange(Bundle bundle) {
    // TODO: implement exchange
    throw UnimplementedError();
  }

  @override
  getAccounts(List userIds) {
    // TODO: implement getAccounts
    throw UnimplementedError();
  }

  @override
  getBuddies(String userId) {
    // TODO: implement getBuddies
    throw UnimplementedError();
  }

  @override
  getRank(String rankName, {int limit = 10}) {
    // TODO: implement getRank
    throw UnimplementedError();
  }

  @override
  merge(String resource) {
    // TODO: implement merge
    throw UnimplementedError();
  }

  @override
  refreshAccount() {
    // TODO: implement refreshAccount
    throw UnimplementedError();
  }

  @override
  updateAccount({String? displayName, String? avatarUrl}) {
    // TODO: implement updateAccount
    throw UnimplementedError();
  }

  @override
  updateMessages() {
    // TODO: implement updateMessages
    throw UnimplementedError();
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
