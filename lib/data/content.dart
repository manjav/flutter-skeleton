import 'package:lingai/app_export.dart';

class Contents {
  List<ParentContent> categories = [];
  Contents.initialize(Map map) {
    for (var entry in map.entries) {
      var groups = <ParentContent>[];
      for (var gentry in entry.value["groups"].entries) {
        groups.add(ParentContent.initialize(gentry.key, gentry.value));
      }
      groups.sort((a, b) => a.index - b.index);
      var category = ParentContent.initialize(entry.key, entry.value);
      category.children = groups;
      categories.add(category);
    }
    categories.sort((a, b) => a.index - b.index);
  }
}

class Content {
  final String id;
  final int index;
  Content(this.id, this.index);
}

class ParentContent extends Content {
  List<Content> children = [];
  final String title, description, iconUrl;
  ParentContent(
    super.id,
    super.index,
    this.title,
    this.description,
    this.iconUrl,
  );
  static ParentContent initialize(String id, Map map) {
    return ParentContent(
      id,
      map["index"],
      map["title"],
      map["description"],
      map["iconUrl"],
    );
  }
}

class Talk extends Content {
  final String personId, nativeValue, targetValue;
  TalkType type = TalkType.none;
  Talk(
    super.id,
    super.index,
    this.personId,
    this.nativeValue,
    this.targetValue,
  );
  static Talk initialize(
      int index, Map map, String nativeLanguage, String targetLanguage) {
    var talk = Talk(
      map["id"],
      index,
      map["person_id"],
      map[nativeLanguage],
      map[targetLanguage],
    );
    talk.type = talk.index % 2 == 0 ? TalkType.bot : TalkType.user;
    return talk;
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
