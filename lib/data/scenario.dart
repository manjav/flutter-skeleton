import 'package:lingai/app_export.dart';

class Scenario {
  String botName = "", botAvatar = "";
  List<Talk> thread = [];
  String nativeLanguage = "", targetLanguage = "";

  Scenario(Map map) {
    botName = map["botName"];
    botAvatar = map["botAvatar"];
    nativeLanguage = map["nativeLanguage"];
    targetLanguage = map["targetLanguage"];
    thread = [];

    var index = 0, talkIndex = 0;
    var lastType = ChatType.none;
    Talk currentTalk = Talk(talkIndex);
    while (index < map["thread"].length) {
      var t = ChatTypeExtension.getEnum(map["thread"][index]["type"]);
      if (t == ChatType.hint && lastType != ChatType.none) {
        thread.add(currentTalk);
        currentTalk = Talk(++talkIndex);
      }
      lastType = t;
      currentTalk.chats
          .add(Chat(type: t, value: map["thread"][index]["value"]));
      if (t == ChatType.user) {
        currentTalk.chats.add(
            Chat(type: ChatType.stt, value: map["thread"][index]["value"]));
      }
      index++;
    }
    thread.add(currentTalk);
  }
}

enum ChatType { none, hint, user, stt, bot }

class ChatTypeExtension {
  static ChatType getEnum(String type) {
    for (var value in ChatType.values) {
      if (value.name == type) return value;
    }
    return ChatType.none;
  }
}

class Chat {
  final ChatType type;
  final String value;
  Chat({required this.type, required this.value});
  bool get isChat => type == ChatType.user || type == ChatType.bot;
  Narrator get narrator => switch (type) {
        ChatType.user => Narrator.nova,
        ChatType.bot => Narrator.fable,
        _ => Narrator.onyx,
      };
}

class Talk {
  final int index;
  List<Chat> chats = [];
  Talk(this.index);
  Chat first(ChatType type) => chats.firstWhere((c) => c.type == type);
}
