import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nakama/nakama.dart';

import '../app_export.dart';

class AccountProvider extends ChangeNotifier {
  late Account account;
  Map<String, int> scores = {};
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

  Future<void> loadTalks(GroupContent group) async {
    List list = await serviceLocator<NetConnector>()
        .rpc("content_contents", params: {"groupId": group.id});
    list.sort((a, b) => a["index"] - b["index"]);
    var talks = <Talk>[];
    for (var i = 0; i < list.length; i++) {
      talks.add(
        Talk.create(
          i,
          list[i],
          account.user.langTag!,
          metadata["targetLanguage"],
        ),
      );
    }
    group.children = talks;
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
}
