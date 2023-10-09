import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/services_bloc.dart';
import '../../data/core/account.dart';
import '../../data/core/building.dart';
import '../../main.dart';
import '../../services/connection/noob_socket.dart';
import '../../utils/utils.dart';
import 'ranking.dart';

class Tribe {
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
  List<Member> members = [];
  ChatNotifier chat = ChatNotifier([]);

  Tribe(Map? map) : super() {
    if (map == null) return;
    id = map["id"];
    gold = map["gold"];
    status = map["status"];
    population = map["member_count"];
    levels[Buildings.offense.id] = map["offense_building_level"];
    levels[Buildings.defense.id] = map["defense_building_level"];
    levels[Buildings.cards.id] = map["cooldown_building_level"];
    levels[Buildings.base.id] = map["mainhall_building_level"];
    donatesCount = map["donates_number"];
    score = (map["score"]);
    weeklyScore = (map["weekly_score"]);
    rank = (map["rank"]);
    weeklyRank = (map["weekly_rank"]);
    name = map["name"];
    description = map["description"];
  }

  int _getInt(Map map, String key, [defaultValue = 0]) {
    if (!map.containsKey(key)) return defaultValue;
    return map[key] is int ? map[key] : int.parse(map[key]);
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

  sendMessage(BuildContext context, Account account, String text) async {
    if (text.isEmpty) return;
    var now = DateTime.now();
    var chat = {
      "id": now.secondsSinceEpoch,
      "text": text,
      "messageType": 1,
      "channel": "tribe$id",
      "push_message_type": "chat",
      "sender": account.get(AccountField.name),
      "avatar_id": account.get(AccountField.avatar_id),
      "creationDate":
          now.secondsSinceEpoch + account.get<int>(AccountField.delta_time),
      "timestamp": (now.microsecondsSinceEpoch -
              MyApp.startTime.microsecondsSinceEpoch) /
          1000
    };
    var noob = BlocProvider.of<ServicesBloc>(context).get<NoobSocket>();
    await noob.publish(jsonEncode(chat));
  }
}

class ChatNotifier extends ValueNotifier<List<NoobChatMessage>> {
  ChatNotifier(super.value);

  get length => value.length;

  void add(NoobChatMessage message) {
    value.add(message);
    notifyListeners();
  }
}
