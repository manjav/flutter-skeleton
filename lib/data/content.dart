import 'package:lingai/app_export.dart';

class Content {
  int index = 0;
  final String id;
  final Content? parent;
  ContentType type = ContentType.none;
  String nativeValue = "", targetValue = "";
  Content.create(this.parent, this.id, Map map) {
    index = map["index"];
  }

  bool get isChat => type == ContentType.bot || type == ContentType.user;
  bool get isQuiz => type == ContentType.user;

  static List<ParentContent> createAll(Map map) {
    List<ParentContent> categories = [];
    for (var entry in map.entries) {
      var category = ParentContent.create(null, entry.key, entry.value);
      var groups = <GroupContent>[];
      for (var gentry in entry.value["groups"].entries) {
        groups.add(GroupContent.create(category, gentry.key, gentry.value));
      }
      groups.sort((a, b) => a.index - b.index);
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
  ParentContent.create(Content? parent, String id, Map map)
      : super.create(parent, id, map) {
    title = map["title"] ?? "";
    description = map["description"] ?? "";
    iconUrl = map["iconUrl"] ?? "";
  }
}

class GroupContent extends ParentContent {
  GroupContent.create(super.parent, super.id, super.map) : super.create() {
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
      result.add(Word.create(parent, ids[i],
          {"native": natives[i], "target": targets[i], "index": i}));
    }

    return result;
  }
}

class Talk extends Content {
  int slideIndex = 0;
  double scrollPosition = 0;
  Set<String> get words => {...targetValue.split(" ")};
  Talk.create(Content parent, int index, Map map, String nativeLanguage,
      String targetLanguage, String name)
      : super.create(parent, map["id"], map) {
    slideIndex = map["slide_index"] ?? 0;
    nativeValue = map[nativeLanguage].replaceFirst(RegExp(r'%n'), name);
    targetValue = map[targetLanguage].replaceFirst(RegExp(r'%n'), name);
    if (map["type"] == "introduce") {
      type = ContentType.intro;
    } else if (map["type"].endsWith("_1")) {
      type = ContentType.user;
    } else if (map["type"].endsWith("_2")) {
      type = ContentType.bot;
    } else {
      type = map["type"] == "image" ? ContentType.image : ContentType.hint;
    }
  }
}

enum ContentType { none, category, group, name, hint, user, bot, image }

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
  Word.create(Content? parent, String id, Map map)
      : super.create(parent, id, map) {
    count = map["count"] ?? 0;
    nativeValue = map["native"] ?? "";
    targetValue = map["target"] ?? "";
    if (!map.containsKey("first")) return;
    firstReview = DateExtension.fromDaysSinceEpoch(map["first"]);
    lastReview = DateExtension.fromDaysSinceEpoch(map["last"]);
    nextReview = DateExtension.fromDaysSinceEpoch(map["next"]);
  }

  static Word fromMap(Content? parent, String id, Map map) =>
      Word.create(parent, id, map);

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
      map[entry.key] = Word.fromMap(null, entry.key, entry.value);
    }
    return map;
  }
}
