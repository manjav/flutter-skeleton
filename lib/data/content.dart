class Contents {
  List<Content> categories = [];
  Contents.initialize(Map map) {
    for (var entry in map.entries) {
      var groups = <Content>[];
      for (var gentry in entry.value["groups"].entries) {
        groups.add(Content.initialize(gentry.key, gentry.value));
      }
      groups.sort((a, b) => a.index - b.index);
      var category = Content.initialize(entry.key, entry.value);
      category.children = groups;
      categories.add(category);
    }
    categories.sort((a, b) => a.index - b.index);
  }
}

class Content {
  final int index;
  List<Content> children = [];
  final String id, title, description, iconUrl;
  Content(this.index, this.id, this.title, this.description, this.iconUrl);
  static Content initialize(String id, Map map) {
    return Content(
        map["index"], id, map["title"], map["description"], map["iconUrl"]);
  }
}
