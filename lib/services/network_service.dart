import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_connection_interface.dart';
import 'package:http/http.dart' as http;
import 'package:nakama/api.dart';
import 'package:nakama/nakama.dart';
import 'package:nakama/src/session.dart' as model;

import '../utils/device.dart';
import 'core/infra.dart';
import 'core/prefs.dart';
import 'core/rules.dart';
import 'core/units.dart';

abstract class NetworkService {
  // Future<NetConnection> initialize();
  connect();
  refreshAccount();
  updateAccount({String? displayName, String? avatarUrl});
  getAccounts(List userIds);
  Future<Result<T>> rpc<T>(RpcId id, {String? payload});
  exchange(Bundle bundle);
  merge(String resource);
  getRank(String rankName, {int limit = 10});
  getBuddies(String userId);
  updateResponse(LoadingState state, String message);
  updateMessages();

  printTest();

  // Future<NetConnection> disconnect();
}
// ignore_for_file: implementation_imports, depend_on_referenced_packages

class Network implements NetworkService {
  Network(
      // super.services
      );
  var baseURL = "https://alchemy.turnedondigital.com/looterkings/";

  dynamic config;
  late Rules rules;
  late Account account;
  late MyClient _nakamaClient;
  model.Session? _session;
  var messages = <Message>[];

  final _serverLessMode = false;
  final _localHost = ''; //'192.168.1.101';
  final _stagingMode = false;
  final _rpcTimes = <RpcId, int>{};

  var response = NetResponse();

  @override
  printTest() {
    print("network print");
  }

  @override
  connect() async {
    // await _konvert();

    await _loadConfig();
    log("Config loaded.");
    await _connection();
    log("Nakama connected.");

    if (_session == null) {
      updateResponse(LoadingState.disconnect, "");
      return;
    }
    // Load account
    await refreshAccount();
    log("Account data loaded.");

    // Load the resources data

    ///NOTE hamiiid
    // var resources = await rpc<List>(RpcId.resourceData);

    // Load the rules data
    rules = Rules();
    // rules.wallet.init(json.decode(account.wallet));//NOTE Hamiiid - because of the rules class this line commented

    // if (rules.wallet['_explore'] < 1) {
    //   TutorSteps.welcome.commit(true);
    // } else if (rules.wallet['_merge'] < 1) {
    //   TutorSteps.exploreFirst.commit(true);
    // } else if (rules.wallet['_order'] > 0) {
    TutorSteps.fine.commit();
    // }

    //NOTE hamiiid
    // var rulesResult = await rpc(RpcId.rulesGet);

//NOTE Hamiiid - because of the rules class this line commented
    // rules.load(rulesResult.data, resources);

    await updateOrders();
    log("Orders updated.");

    await updateMessages();
    log("Messages updated.");

    updateResponse(
        LoadingState.connect, "Account ${account.user.username} connected.");
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
    _nakamaClient = MyClient(
        host: config['server']['host'],
        port: config['server']['port'],
        serverKey: 'defaultkey',
        ssl: false);

    var timezone = DateTime.now().timeZoneOffset.inSeconds;
    var location = await FlutterNativeTimezone.getLocalTimezone();
    var store = "GooglePlay";
    var data = {
      "timezone": "$timezone",
      "location": location,
      "store": store,
      "latestVersion": "app_version".l(),
      "displayName": "Player_${Utils.getRandomString(4)}",
      "device":
          '{"model":"${Device.model}", "osVersion":"${Device.osVersion}", "baseVersion":"${Device.baseVersion}"}'
    };

    try {
      _session = await _nakamaClient.authenticateDevice(
          deviceId: Device.adId, vars: data);
    } catch (e) {
      updateResponse(LoadingState.disconnect, e.toString());
    }
  }

  @override
  refreshAccount() async {
    account = await _nakamaClient.getAccount(_session!);
  }

  Future<Result> updateOrders([List? orderList]) async {
    if (orderList == null) {
      var result = await rpc(RpcId.orderGet);
      if (!result.response.isSuccess()) return result;
      orderList = result.data;
    }
    //NOTE Hamiiid - because of the rules class this line commented

    // rules.orders.clear();
    var resources = <String>[];
    for (var orderData in orderList!) {
      var order = Order.fromData(orderData);
      // rules.orders[order.id] = order; //NOTE hamiiid
      for (var r in order.bundle.incomes.keys) {
        if (!r.startsWith('_')) {
          resources.add(r);
        }
      }
    }
    return Result(Responses.success, "", "rules.orders");
  }

  @override
  updateAccount({String? displayName, String? avatarUrl}) async {
    // await _nakamaClient.updateAccount(
    //     session: _session!, displayName: displayName, avatarUrl: avatarUrl);
    // notifyListeners();
  }

  @override
  Future<List<PublicAccount>> getAccounts(List userIds) async {
    if (userIds.isEmpty) {
      return [];
    }
    var data = await _nakamaClient.rpc(
        session: _session!,
        id: RpcId.accountsGet.name,
        payload: userIds.join(','));
    var accounts = <PublicAccount>[];
    var list = data.payload.split('|');
    for (var item in list) {
      accounts.add(PublicAccount.fromMap(json.decode(item)));
    }
    return accounts;
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
      var rpc = await _nakamaClient.rpc(
          session: _session!, id: id.name, payload: payload);
      var res = json.decode(rpc.payload);
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
  Future<Result> exchange(Bundle bundle) async {
    // var result = rules.exchange(bundle);
    // if (!result.response.isSuccess()) return result;
    // bundle.incomes.forEach((key, value) {
    //   rules.resources[key]?.isNew = false;
    // });
    // _updateIslandProgress(result.data);
    // rules.notifyChanges();

    Result tempFake = Result(Responses.notEnough, "message",
        "_data"); //NOTE hamiiid just fot the return type

    // return result;
    return tempFake;
  }

  _updateIslandProgress(Map<String, int> map) {
    // for (var r in map.keys) {
    //   if (!r.startsWith("_")) {
    //     rules.resources[r]!.count = rules.wallet[r];
    //   }
    // }

    // // Reset island item founds
    // for (var o in rules.islands.values) {
    //   o.itemFoundCount = 0;
    // }
    // for (var r in rules.resources.values) {
    //   if (r.island == null) continue;
    //   if (rules.wallet.containsKey(r.type)) {
    //     ++rules.islands[r.island]!.itemFoundCount;
    //   }
    // }
  }

  @override
  merge(String resource) async {
    // var result = await rpc<Map<String, dynamic>?>(RpcId.merge,
    //     payload: '{"merge":"$resource"}');
    // if (!result.response.isSuccess()) {
    //   rules.notifyChanges(args: {"mergeResult": result});
    //   return;
    // }
    // rules.resources.currentMergeLinks.clear();
    // // services.get<Analytics>().funnle("merge");
    // var bundle = Bundle.fromData(result.data);
    // await exchange(bundle);
    // var rewardKey = bundle.outcomes.keys.firstWhere((k) => !k.startsWith('_'));
    // rules.notifyChanges(args: {
    //   "mergeResult": result,
    //   "reward": rules.resources[rewardKey]!,
    //   "bundle": bundle
    // });
  }

  @override
  Future<LeaderboardRecordList> getRank(String rankName,
      {int limit = 10}) async {
    var result = await _nakamaClient.listLeaderboardRecords(
        session: _session!,
        limit: limit,
        leaderboardName: rankName,
        ownerIds: [account.user.id]);
    return result;
  }

  // Future<Buddies>
  @override
  getBuddies(String userId) async {
    // var result = await rpc<Map>(RpcId.buddyGet, payload: '{"id":"$userId"}');
    // var buddies = Buddies();
    // if (result.response.isSuccess()) {
    //   buddies.followers = [...result.data['followers']];
    //   buddies.followings = [...result.data['followings']];
    // }
    // return buddies;
  }

  @override
  updateResponse(LoadingState state, String message) {
    response.state = state;
    response.message = message;
    // notifyListeners();
  }

  @override
  updateMessages() async {
    // var result =
    //     await services.get<Network>().rpc<List>(RpcId.notificationsGet);
    // if (result.response.isSuccess()) {
    //   messages.clear();
    //   for (var i = 0; i < result.data.length; i++) {
    //     messages.add(Message.fromData(result.data[i]));
    //   }
    // }
    // return messages;
  }

  /* _konvert() async {
    var images = {
    };
    for (var i = 0; i < images.entries.length; i++) {
      var response = await http.get(Uri.parse(
          '${baseURL}konvert.php?${_stagingMode ? 'staging=true&' : ''}in=${images.entries.elementAt(i).key}&out=${images.entries.elementAt(i).value}'));
      print("$i / ${images.entries.length}");
    }
  } */
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

enum RpcId {
  accountsGet,
  accountLevelup,
  accountLinkDevice,
  accountLinkGoogle,
  auctionForce,
  auctionGet,
  buddyGet,
  buddyFollow,
  buddyUnfollow,
  merge,
  mergeMake,
  notificationsGet,
  islandUpgrade,
  purchaseVerify,
  orderFill,
  orderGet,
  orderSkip,
  resourceAdd,
  resourceData,
  resourceLoot,
  resourceExplore,
  rulesGet,
}

extension RpcIdEx on RpcId {
  String get name {
    switch (this) {
      case RpcId.accountLevelup:
        return "account_levelup";
      case RpcId.accountLinkDevice:
        return "account_link_device";
      case RpcId.accountLinkGoogle:
        return "account_link_google";
      case RpcId.accountsGet:
        return "accounts_get";
      case RpcId.auctionGet:
        return "auction_get";
      case RpcId.auctionForce:
        return "auction_force";
      case RpcId.buddyGet:
        return "buddy_get";
      case RpcId.buddyFollow:
        return "buddy_follow";
      case RpcId.buddyUnfollow:
        return "buddy_unfollow";
      case RpcId.merge:
        return "merge";
      case RpcId.mergeMake:
        return "merge_make";
      case RpcId.notificationsGet:
        return "notifications_get";
      case RpcId.orderFill:
        return "order_fill";
      case RpcId.orderGet:
        return "order_get";
      case RpcId.orderSkip:
        return "order_skip";
      case RpcId.islandUpgrade:
        return "island_upgrade";
      case RpcId.purchaseVerify:
        return "purchase_verify";
      case RpcId.resourceAdd:
        return "resource_add";
      case RpcId.resourceData:
        return "resource_data";
      case RpcId.resourceLoot:
        return "resource_loot";
      case RpcId.resourceExplore:
        return "resource_explore";
      case RpcId.rulesGet:
        return "rules_get";
      default:
        return "default_id";
    }
  }
}

class MyClient extends NakamaGrpcClient {
  MyClient(
      {required super.host,
      required super.ssl,
      required super.serverKey,
      required super.port});

  Future<Rpc> rpc({
    required model.Session session,
    required String id,
    String? payload,
  }) async {
    return await rawGrpcClient.rpcFunc(
      Rpc(id: id, payload: payload),
      options: CallOptions(
        metadata: {'authorization': 'Bearer ${session.token}'},
      ),
    );
  }
}

enum AuthMode {
  games,
  device,
}

extension AuthModeEx on AuthMode {
  int get id => index + 1;
}

class PublicAccount {
  var user = User();
  var wallet = <String, int>{};

  int get age =>
      user.updateTime.toDateTime().daysSinceEpoch -
      user.createTime.toDateTime().daysSinceEpoch;

  int get gap =>
      DateTime.now().daysSinceEpoch -
      user.updateTime.toDateTime().daysSinceEpoch;

  static PublicAccount fromMap(obj) {
    var pubAccount = PublicAccount();
    pubAccount.wallet = Map.castFrom(obj['wallet']);
    pubAccount.user = User(
      id: obj['user']['userId'],
      avatarUrl: obj['user']['avatarUrl'],
      displayName: obj['user']['displayName'],
      langTag: obj['user']['langTag'],
      location: obj['user']['location'],
      createTime: Timestamp(seconds: Int64(obj['user']['createTime'])),
      updateTime: Timestamp(seconds: Int64(obj['user']['updateTime'])),
    );
    return pubAccount;
  }

  static PublicAccount fromAccount(Account account,
      [Map<String, int>? wallet]) {
    var pubAccount = PublicAccount();
    pubAccount.wallet = wallet ?? Map.castFrom(json.decode(account.wallet));
    pubAccount.user = User(
      id: account.user.id,
      avatarUrl: account.user.avatarUrl,
      displayName: account.user.displayName,
      langTag: account.user.langTag,
      location: account.user.location,
      createTime: account.user.createTime,
      updateTime: account.user.updateTime,
    );
    return pubAccount;
  }
}

extension AccountExt on Account {
  PublicAccount toPublic([Map<String, int>? wallet]) =>
      PublicAccount.fromAccount(this, wallet);
}
