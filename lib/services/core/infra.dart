import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_skeleton/services/core/rules.dart';

class Result<Type> {
  final Responses response;
  final String message;
  final Type? _data;
  Result(this.response, this.message, this._data);
  Type get data => _data!;
}

class Bundle {
  var outcomes = <String, int>{};
  var incomes = <String, int>{};
  Bundle([Map<String, int>? outcomes, Map<String, int>? incomes]) {
    if (outcomes != null) this.outcomes = outcomes;
    if (incomes != null) this.incomes = incomes;
  }

  static Bundle fromData(dynamic data) {
    return Bundle(
        Map.castFrom(data["outcomes"]), Map.castFrom(data['incomes']));
  }
}

enum Responses {
  alreadyExists,
  notEnough,
  notFound,
  success,
  unAvailable,
  unknown,
}

enum Bundles { search, shop_0 }

extension ResponsesintEx on int {
  Responses toResponse() {
    for (var r in Responses.values) {
      if (this == r.value) return r;
    }
    return Responses.unknown;
  }
}

class StringMap<T> {
  final map = <String, T>{};
  void init(Map<String, dynamic> data) {
    data.forEach((key, value) {
      map[key] = value;
    });
  }

  T? operator [](String key) => map[key];
  void operator []=(String key, T value) {
    map[key] = value;
  }

  T? remove(Object? key) => map.remove(key);
  bool containsKey(Object? key) => map.containsKey(key);
  bool get isEmpty => throw map.isEmpty;
  Iterable<MapEntry<String, T>> get entries => map.entries;
  Iterable<String> get keys => map.keys;
  Iterable<T> get values => map.values;
  int get length => map.length;
}

extension ResponsesEx on Responses {
  int get value {
    switch (this) {
      case Responses.alreadyExists:
        return -3;
      case Responses.notEnough:
        return -1;
      case Responses.notFound:
        return -4;
      case Responses.success:
        return 0;
      case Responses.unAvailable:
        return -2;
      default:
        return -10;
    }
  }

  bool isSuccess() => this == Responses.success;
}

class Wallet extends StringMap<int> {
  @override
  int operator [](String key) => map[key] ?? 0;
}

class Resources extends StringMap<Resource> {
  Rules rules;
  final currentMergeLinks = <String, Resource>{};
  Resources(this.rules) : super();

  List<Resource> getMergeOffers(List<String> siblings) {
    var offers = <Resource>[];
    //NOTE Hamiiid - NA

    // for (var resource in rules.resources.values) {
    //   if (resource.links.length == siblings.length) {
    //     var found = true;
    //     for (var sibling in siblings) {
    //       if (!resource.links.containsKey(sibling)) {
    //         found = false;
    //         break;
    //       }
    //     }
    //     if (found) {
    //       offers.add(resource);
    //     }
    //   }
    // }
    return offers;
  }

  Map<String, Resource> findResourceSiblings(String resource) {
    currentMergeLinks.clear();
    currentMergeLinks[resource] = map[resource]!;
    for (var entry in entries) {
      if (entry.value.links.containsKey(resource)) {
        for (var key in entry.value.links.keys) {
          if (key != resource) {
            currentMergeLinks[key] = map[key]!;
          }
        }
      }
    }
    return currentMergeLinks;
  }
}

class Resource extends ChangeNotifier {
  var count = 0;
  var id = 0;
  var picked = 0;
  var type = '';
  var title = '';
  String? island;
  String? origin;
  var description = '';
  var price = 0;
  var usage = -1;
  var _level = 0;
  var links = <String, int>{};
  var isNew = false;
  var key = GlobalKey();
  Resource fromDynamic(dynamic d, int count) {
    title = d['title'] ?? '';
    id = d['id'] ?? 0;
    type = "${d['id']}";
    island = d['island'];
    origin = d['origin'];
    price = d['price'] ?? 0;
    usage = d['usage'] ?? -1;
    _level = d['level'];
    description = d['description'] ?? '';
    links = Map.castFrom(d['links']);
    this.count = count;
    return this;
  }

  bool get isPrimitive => origin != null;
  bool get isFinal => usage == 0;
  bool get isRare => _level == 0 && isPrimitive;

  void dispatchEvent() {
    notifyListeners();
  }
}

class AuctionRules {
  int bidStep = 10;
  int auctionTime = 24 * 60 * 3600;
}

class Level {
  final int length;
  final Map<String, int> rewards;
  Level(this.length, this.rewards);
}

class Island {
  final int index;
  final String id;
  final Map<String, Origin> origins;
  final double rarity;
  final int unlockAt;
  final Bundle bundle;
  final Bundle unlockBundle;
  final GlobalKey key;
  var itemCount = 0;
  var itemFoundCount = 0;
  var level = 0;
  var initialized = false;
  // SMIBool? isLock; //NOTE Hamiiid - NA

  Island(this.index, this.id, this.origins, this.level, this.rarity,
      this.unlockAt, this.bundle, this.unlockBundle, this.key);
}

class Origin {
  final String name;
  var position = Offset.zero;
  String? foundItem;
  Result<Bundle>? result;
  var exploreStep = ExploreStep.none;
  Origin(this.name);
}

enum ExploreStep { none, ready, progress, fine, found }

class Order {
  int id;
  int customer;
  int message;
  Bundle bundle;
  Order(this.id, this.customer, this.message, this.bundle);
  static Order fromData(order) {
    return Order(
      order['id'],
      order['customer'],
      order['message'],
      Bundle.fromData(order['bundle']),
    );
  }
}

class Auction {
  final int id;
  final String type;
  final int count;
  final int startPrice;
  final int currentPrice;
  final String owner;
  final String ownerName;
  final int state;
  final int remainingTime;
  Auction(this.id, this.type, this.count, this.startPrice, this.currentPrice,
      this.owner, this.ownerName, this.state, this.remainingTime);
}

class Buddies {
  late var followers = <String>[];
  late var followings = <String>[];
}

class Message {
  var type = MessageType.simple;
  var subject = '';
  var createTime = 0;
  dynamic data;
  String? senderId;
  String? senderAvatarUrl;
  String? senderDisplayName;

  static Message fromData(Map messageData) {
    var message = Message();
    message.type = MessageType.values[messageData['code'] - 1];
    message.subject = messageData['subject'];
    message.senderId = messageData['sender_id'];
    message.createTime = messageData['create_time'];
    var data = jsonDecode(messageData['data']);
    if (data['senderAvatarUrl'] != null) {
      message.senderAvatarUrl = data['senderAvatarUrl'];
      message.senderDisplayName = data['senderDisplayName'];
      message.data = data['data'];
    }
    return message;
  }
}

enum MessageType { simple, link, confirm }
