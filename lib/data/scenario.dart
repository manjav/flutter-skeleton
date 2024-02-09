class Scenario {
  String botName = "", botAvatar = "";
  List<Chat> thread = [];
  Scenario(Map map) {
    botName = map["botName"];
    botAvatar = map["botAvatar"];
    thread = List.generate(
        map["thread"].length,
        (i) => Chat(
            Chat.getEnum(map["thread"][i]["type"]), map["thread"][i]["value"]));
  }
}

enum ChatType { none, hint, user, bot }

class Chat {
  final ChatType type;
  final String text;
  Chat(this.type, this.text);
  static ChatType getEnum(String type) {
    for (var value in ChatType.values) {
      if (value.name == type) return value;
    }
    return ChatType.none;
  }
}
