class Scenario {
  String botName = "", botAvatar = "";
  String nativeLanguage = "", targetLanguage = "";

  Scenario(Map map) {
    botName = map["botName"];
    botAvatar = map["botAvatar"];
    nativeLanguage = map["nativeLanguage"];
    targetLanguage = map["targetLanguage"];
    thread = [];
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
