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
  Talk(
    super.id,
    super.index,
    this.personId,
    this.nativeValue,
    this.targetValue,
  );
  static Talk initialize(
      Map map, String nativeLanguage, String targetLanguage) {
    return Talk(
      map["id"],
      map["index"],
      map["person_id"],
      map[nativeLanguage],
      map[targetLanguage],
    );
  }
}
