import 'package:lifetalk/app_export.dart';

class Content {
  int index = 0;
  final String id;
  final Content? parent;
  ContentType type = ContentType.none;
  TranslationSide side = TranslationSide.none;
  String nativeValue = "", targetValue = "";
  Content.create(this.parent, this.id, Map map) {
    index = map["index"] ?? 0;
  }

  bool get isChat => type == ContentType.bot || type == ContentType.user;
  bool get isQuiz =>
      type == ContentType.answer ||
      type == ContentType.repeat ||
      type == ContentType.translate;
  bool get isStation => isQuiz || type == ContentType.video;

  static List<ParentContent> createAll(Map map) {
    List<ParentContent> categories = [];
    for (var entry in map.entries) {
      var category = ParentContent.create(
        null,
        ContentType.category,
        entry.key,
        entry.value,
      );

      var groups = <ParentContent>[];
      for (var gentry in entry.value["groups"].entries) {
        groups.add(ParentContent.create(
          category,
          ContentType.group,
          gentry.key,
          gentry.value,
        ));
      }
      groups.sort((a, b) => a.index - b.index);
      category.type = ContentType.category;
      category.children = groups;
      categories.add(category);
    }
    categories.sort((a, b) => a.index - b.index);
    return categories;
  }

  String getText(TranslationSide side) {
    return switch (side) {
      TranslationSide.native => nativeValue,
      TranslationSide.target => targetValue,
      _ => "",
    };
  }
}

class ParentContent extends Content {
  List<Content> children = [];
  int passLevel = 0;
  String title = "", description = "", iconUrl = "", mode = "";
  ParentContent.create(
    Content? parent,
    ContentType type,
    String id,
    Map map,
  ) : super.create(parent, id, map) {
    this.type = type;
    title = map["title"] ?? "";
    description = map["description"] ?? "";
    iconUrl = map["iconUrl"] ?? "";
    mode = map["mode"] ?? "";
  }
}

class Talk extends Content {
  int version = 0;
  int score = 0;
  QuizRecord? lastRecord;
  Set<String> get words => {...targetValue.split(" ")};
  Talk.create(Content parent, int index, Map map, String nativeLanguage,
      String targetLanguage, String name)
      : super.create(parent, map["id"], map) {
    nativeValue = map[nativeLanguage].replaceFirst(RegExp(r'%n'), name);
    targetValue = map[targetLanguage].replaceFirst(RegExp(r'%n'), name);
    if (map["type"].endsWith("_1")) {
      type = ContentType.user;
    } else if (map["type"].endsWith("_2")) {
      type = ContentType.bot;
    } else if (map["type"].startsWith("avatar_")) {
      type = ContentType.avatar;
      version = AvatarExpression.values
          .indexWhere((e) => e.name == map["type"].substring(7));
    } else {
      if (map["type"] == "translate_n") {
        map["type"] = "translate";
        version = 1;
      }
      if (map["type"] == "uncover") {
        print("dssads");
      }
      type = ContentType.getEnum(map["type"]);
    }
  }

  TranslationSide get textSide {
    if (type == ContentType.caption ||
        (type == ContentType.translate && version > 0)) {
      return TranslationSide.native;
    }
    if (type == ContentType.repeat) return TranslationSide.target;
    return TranslationSide.none;
  }

  Narrator get narrator =>
      textSide == TranslationSide.native ? Narrator.ali : Narrator.onyx;
}

enum TranslationSide { none, native, target }

enum ContentType {
  none,
  category,
  group,
  slide,
  serie,
  talk,
  head,
  text,
  caption,
  repeat,
  translate,
  answer,
  user,
  bot,
  image,
  video,
  avatar,
  uncover;

  ContentType getChild() {
    return switch (this) {
      ContentType.serie => ContentType.slide,
      ContentType.slide => ContentType.talk,
      _ => none,
    };
  }

  double get micIndex => switch (this) {
        ContentType.translate => 1,
        ContentType.answer => 2,
        _ => 0,
      };

  static ContentType getEnum(String type) {
    for (var value in ContentType.values) {
      if (value.name == type) return value;
    }
    return ContentType.none;
  }
}

enum PresentMode {
  none,
  native,
  target,
  both;

  bool get hasNative => this == PresentMode.native || this == PresentMode.both;
  bool get hasTarget => this == PresentMode.target || this == PresentMode.both;
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
