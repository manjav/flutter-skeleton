import 'package:lingai/app_export.dart';

class Content {
  int index = 0;
  final String id;
  ContentType type = ContentType.none;
  String nativeValue = "", targetValue = "";
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
      category.type = ContentType.category;
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
  GroupContent.create(super.id, super.map) : super.create() {
    type = ContentType.group;
  }

  List<Word> get words {
    var result = <Word>[];
    var ids = ["Egg", "Yogurt", "Bread", "Lemon"];
    var targets = ["Yumurta", "Yogurt", "Ekmek", "Limon"];
    var natives = ["تخم مرغ", "ماست", "نان", "لیمو"];
    // Set<String> all = {};
    // for (var talk in children) {
    //   all.addAll((talk as Talk).words);
    // }
    for (var i = 0; i < ids.length; i++) {
      result.add(Word.create(
          ids[i], {"native": natives[i], "target": targets[i], "index": i}));
    }

    return result;
  }
}

class Talk extends Content {
  String personId = "";
  Set<String> get words => {...targetValue.split(" ")};
  Talk.create(int index, Map map, String nativeLanguage, String targetLanguage)
      : super.create(map["id"], map) {
    this.index = index;
    personId = map["person_id"];
    nativeValue = map[nativeLanguage];
    targetValue = map[targetLanguage];
    type = index % 2 == 0 ? ContentType.bot : ContentType.user;
  }
}

enum ContentType { none, category, group, hint, user, bot }

extension ContentTypeExtension on ContentType {
  static ContentType getEnum(String type) {
    for (var value in ContentType.values) {
      if (value.name == type) return value;
    }
    return ContentType.none;
  }

  Narrator get narrator => switch (this) {
        ContentType.user => Narrator.nova,
        ContentType.bot => Narrator.fable,
        _ => Narrator.onyx,
      };
}

class Word extends Content {
  int count = 0;
  DateTime? firstReview;
  DateTime? lastReview;
  DateTime? nextReview;
  Word.create(String id, Map map) : super.create(id, map) {
    count = map["count"] ?? 0;
    nativeValue = map["native"] ?? "";
    targetValue = map["target"] ?? "";
    if (!map.containsKey("first")) return;
    firstReview = DateExtension.fromDaysSinceEpoch(map["first"]);
    lastReview = DateExtension.fromDaysSinceEpoch(map["last"]);
    nextReview = DateExtension.fromDaysSinceEpoch(map["next"]);
  }

  static Word fromMap(String id, Map map) => Word.create(id, map);

  Map<String, dynamic> toMap() {
    return {
      "count": count,
      "native": nativeValue,
      "target": targetValue,
      "first": firstReview!.daysSinceEpoch,
      "last": lastReview!.daysSinceEpoch,
      "next": nextReview!.daysSinceEpoch,
    };
  }

  static Map<String, Word> allFromMap(Map data) {
    var map = <String, Word>{};
    for (var entry in data.entries) {
      map[entry.key] = Word.fromMap(entry.key, entry.value);
    }
    return map;
  }
}
