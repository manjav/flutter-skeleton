import 'package:lingai/app_export.dart';

class Content {
  final String id;
  int index = 0;
  Content.create(this.id, Map map) {
    index = map["index"];
  }

  static List<ParentContent> createAll(Map map) {
  List<ParentContent> categories = [];
    for (var entry in map.entries) {
      var groups = <GroupContent>[];
      for (var gentry in entry.value["groups"].entries) {
        groups.add(GroupContent.create(gentry.key, gentry.value));
      }
      groups.sort((a, b) => a.index - b.index);
      var category = ParentContent.create(entry.key, entry.value);
      category.children = groups;
      categories.add(category);
    }
    categories.sort((a, b) => a.index - b.index);
    return categories;
  }
}

class ParentContent extends Content {
  List<Content> children = [];
  String title = "", description = "", iconUrl = "";
  ParentContent.create(String id, Map map) : super.create(id, map) {
    title = map["title"];
    description = map["description"];
    iconUrl = map["iconUrl"];
  }
}

class GroupContent extends ParentContent {
  GroupContent.create(super.id, super.map) : super.create();
}

class Talk extends Content {
  TalkType type = TalkType.none;
  String personId = "", nativeValue = "", targetValue = "";
  Talk.create(int index, Map map, String nativeLanguage, String targetLanguage)
      : super.create(map["id"], map) {
    this.index = index;
    personId = map["person_id"];
    nativeValue = map[nativeLanguage];
    targetValue = map[targetLanguage];
    type = index % 2 == 0 ? TalkType.bot : TalkType.user;
  }
}

enum TalkType { none, hint, user, bot }

extension TalkTypeExtension on TalkType {
  static TalkType getEnum(String type) {
    for (var value in TalkType.values) {
      if (value.name == type) return value;
    }
    return TalkType.none;
  }

  Narrator get narrator => switch (this) {
        TalkType.user => Narrator.nova,
        TalkType.bot => Narrator.fable,
        _ => Narrator.onyx,
      };
}
