import 'dart:convert';

import 'package:flutter/widgets.dart';

import '../../app_export.dart';
import '../../main.dart';

class Tribe with ServiceFinderMixin {
  late int id,
      gold,
      status,
      population,
      donatesCount,
      score,
      weeklyScore,
      rank,
      weeklyRank;
  late String name, description;
  final Map<int, int> levels = {};
  ChatNotifier chat = ChatNotifier([]);
  ValueNotifier<List<Opponent>> members = ValueNotifier([]);
  ValueNotifier<NoobChatMessage?> pinnedMessage = ValueNotifier(null);

  Tribe(Map? map) : super() {
    if (map == null) return;
    id = map["id"];
    gold = map["gold"];
    status = map["status"];
    population = map["member_count"];
    levels[Buildings.offense.id] = map["offense_building_level"];
    levels[Buildings.defense.id] = map["defense_building_level"];
    levels[Buildings.cards.id] = map["cooldown_building_level"];
    levels[Buildings.tribe.id] = map["mainhall_building_level"];
    donatesCount = map["donates_number"];
    score = Convert.toInt(map["score"]);
    weeklyScore = Convert.toInt(map["weekly_score"]);
    rank = Convert.toInt(map["rank"]);
    weeklyRank = Convert.toInt(map["weekly_rank"]);
    name = map["name"];
    description = map["description"];
  }

  int getOption(int id, [int? level]) =>
      Building.get_benefit(id.toBuildings(), level ?? levels[id]!);
  int getOptionCost(int id, [int? level]) =>
      Building.get_upgradeCost(id.toBuildings(), level ?? levels[id]!);

  static List<Tribe> initAll(List list) {
    var result = <Tribe>[];
    for (var map in list) {
      result.add(Tribe(map));
    }
    return result;
  }

  loadMembers(BuildContext context, Account account) async {
    if (members.value.isNotEmpty) return;
    try {
      var result = await getService<HttpConnection>(context)
          .rpc(RpcId.tribeMembers, params: {"coach_tribe": false});
      members.value = Opponent.createList(result["members"], account.id);
    } finally {}
  }

  int get onlineMembersCount =>
      members.value.where((member) => member.status > 0).length;

  sendMessage(BuildContext context, Account account, String text) async {
    if (text.isEmpty) return;
    var now = DateTime.now();
    var chat = {
      "id": now.secondsSinceEpoch,
      "text": text,
      "messageType": 1,
      "channel": "tribe$id",
      "push_message_type": "chat",
      "sender": account.name,
      "avatar_id": account.avatarId,
      "creationDate": now.secondsSinceEpoch + account.deltaTime,
      "timestamp": (now.microsecondsSinceEpoch -
              MyApp.startTime.microsecondsSinceEpoch) /
          1000
    };
    await getService<NoobSocket>(context).publish(jsonEncode(chat));
  }

  pinMessage(
      BuildContext context, Account account, NoobChatMessage message) async {
    try {
      await getService<HttpConnection>(context).tryRpc(
          context, RpcId.tribePinMessage,
          params: {"title": "", "message": message.text});
      if (context.mounted) {
        loadPinnedMessage(context, account);
      }
    } finally {}
  }

  loadPinnedMessage(BuildContext context, Account account) async {
    try {
      var data = await getService<HttpConnection>(context)
          .tryRpc(context, RpcId.tribeGetPinnedMessages);
      if (data["messages"].isEmpty) return null;
      var msg = data["messages"].first;
      pinnedMessage.value = NoobChatMessage({
        "id": msg["id"],
        "text": msg["text_fa"],
        "channel": "pin",
        "creationDate": msg["created_at"],
        "messageType": msg["message_type"],
        "timestamp": (DateTime.now().microsecondsSinceEpoch -
                MyApp.startTime.microsecondsSinceEpoch) /
            1000,
      }, account);
    } finally {}
  }
}

class ChatNotifier extends ValueNotifier<List<NoobChatMessage>> {
  ChatNotifier(super.value);

  get length => value.length;

  void add(NoobChatMessage message) {
    value.add(message);
    notifyListeners();
  }

  void remove(NoobChatMessage message) {
    value.remove(message);
    notifyListeners();
  }
}