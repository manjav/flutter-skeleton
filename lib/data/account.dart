import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nakama/nakama.dart';

import '../app_export.dart';

class AccountProvider extends ChangeNotifier {
  late Account account;
  Map<String, int> scores = {};
  Map<String, Word> words = {};
  List<ParentContent> contents = [];
  Map<String, dynamic> metadata = {};

  void initialize(dynamic account) {
    this.account = account;
    metadata = jsonDecode(account.user.metadata!);
  }

  Future<void> update({
    String? avatarUrl,
    String? displayName,
    String? nativeLanguage,
    String? targetLanguage,
  }) async {
    var params = {};
    if (displayName != null) params["displayName"] = displayName;
    if (avatarUrl != null) params["avatarUrl"] = avatarUrl;
    if (nativeLanguage != null) params["nativeLanguage"] = nativeLanguage;
    if (targetLanguage != null) {
      metadata["targetLanguage"] = targetLanguage;
      params["metadata"] = metadata;
    }
    if (params.isEmpty) return;
    await serviceLocator<NetConnector>().rpc("account_update", params: params);
    await refresh();
  }

  Future<void> refresh() async {
    account = await serviceLocator<NetConnector>().getAccount();
    metadata = jsonDecode(account.user.metadata!);
    notifyListeners();
  }

  Future<List<ParentContent>> loadCategories() async {
    // Load Contents
    var data = await serviceLocator<NetConnector>().rpc("content_categories");
    contents = Content.createAll(data);
    notifyListeners();
    return contents;
  }

  Future<void> loadGroup(ParentContent group) async {
    List list = await serviceLocator<NetConnector>()
        .rpc("content_contents", params: {"groupId": group.id});
    _addContentChildren(group, list, ContentType.serie);
  }

  void _addContentChildren(ParentContent group, List list, ContentType type) {
    var children = <Content>[];
    if (type == ContentType.talk) {
      for (var i = 0; i < list.length; i++) {
        children.add(Talk.create(group, i, list[i], account.user.langTag!,
            metadata["targetLanguage"], account.user.displayName!));
      }
    } else {
      final key = "${type.name}_index";
      var map = <int, List>{};
      for (var i = 0; i < list.length; i++) {
        final index = list[i][key];
        if (!map.containsKey(index)) {
          map[index] = [];
        }
        map[index]!.add(list[i]);
      }

      for (var entry in map.entries) {
        var child = ParentContent.create(
            group, type, "${group.id}_${entry.key}", {"index": entry.key});
        _addContentChildren(child, entry.value, type.getChild());
        children.add(child);
      }
    }
    children.sort((a, b) => a.index - b.index);
    group.children = children;
  }

  Future<Map> loadStats(String type) async {
    var stats = await serviceLocator<NetConnector>()
        .rpc("account_stats_get", params: {"type": type});
    return stats;
  }

  Future<void> saveStat(String type, String key, dynamic value) async {
    await serviceLocator<NetConnector>().rpc("account_stat_set",
        params: {"type": type, "key": key, "value": value});
  }

  Future<Map<String, int>> loadScores() async {
    var scores = await loadStats("scores_${metadata["targetLanguage"]}");
    this.scores = Map.castFrom<dynamic, dynamic, String, int>(scores);
    notifyListeners();
    return this.scores;
  }

  Future<Map<String, int>> saveScore(String key, int value) async {
    saveStat("scores_${metadata["targetLanguage"]}", key, value);
    scores[key] = value;
    notifyListeners();
    return scores;
  }

  Future<Map<String, Word>> loadWords() async {
    var data = await loadStats("words_${metadata["targetLanguage"]}");
    words = Word.allFromMap(data);
    notifyListeners();
    return words;
  }

  Future<Map<String, Word>> saveWord(Word word) async {
    saveStat("words_${metadata["targetLanguage"]}", word.id, word);
    words[word.id] = word;
    notifyListeners();
    return words;
  }
}
