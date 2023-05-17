import 'dart:convert';

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
