import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nakama/nakama.dart';

import '../app_export.dart';

class AccountProvider extends ChangeNotifier {
  late Account account;
  // Map<String, Word> words = {};
  List<ParentContent> contents = [];
  Map<String, dynamic> metadata = {};
  Map<String, Map<String, dynamic>> scores = {};
  bool get isTester => (account.user.username ?? "").startsWith("test_");

  void initialize(dynamic account) {
    this.account = account;
    metadata = jsonDecode(account.user.metadata!);
  }

  Future<void> update({
    String? avatarUrl,
    String? username,
    String? displayName,
    String? nativeLanguage,
    String? targetLanguage,
  }) async {
    var params = {};
    if (username != null) params["username"] = username;
    if (displayName != null) params["displayName"] = displayName;
    if (avatarUrl != null) params["avatarUrl"] = avatarUrl;
    if (nativeLanguage != null) params["langTag"] = nativeLanguage;
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
    final list = await serviceLocator<NetConnector>()
        .rpc<List<dynamic>>("content_contents", params: {"groupId": group.id});
    _addContentChildren(group, list, ContentType.serie);
  }

  void _addContentChildren(ParentContent group, List list, ContentType type) {
    var children = <Content>[];
    if (type == ContentType.talk) {
      for (var i = 0; i < list.length; i++) {
        if (list[i]["type"] == "title") {
          group.parent!.title = list[i][account.user.langTag!];
        } else {
          if (list[i]["type"] == "youtube") {
            group.parent!.iconUrl = list[i][Localization.targetLanguage];
          } else {
            children.add(Talk.create(group, i, list[i], account.user.langTag!,
                metadata["targetLanguage"], account.user.displayName!));
          }
        }
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
        if (child.children.isNotEmpty) {
          children.add(child);
        }
      }
    }
    children.sort((a, b) => a.index - b.index);
    group.children = children;
  }

  Future<void> writeStorage({
    required String collectionId,
    required String keyId,
    required Map<String, dynamic> values,
  }) async {
    await serviceLocator<NetConnector>().rpc("account_storage_set", params: {
      "collectionId": collectionId,
      "keyId": keyId,
      "values": values,
    });
  }

  Future<Map<String, Map<String, dynamic>>> loadScores() async {
    scores = await serviceLocator<NetConnector>().readStorage(
      "scores_${account.user.langTag}_${metadata["targetLanguage"]}",
      userId: account.user.id,
    );
    notifyListeners();
    return scores;
  }

  Future<Map<String, Map<String, dynamic>>> saveScore(
    String key,
    Map<String, dynamic> values,
  ) async {
    /// Send to Server
    writeStorage(
      collectionId:
          "scores_${account.user.langTag}_${metadata["targetLanguage"]}",
      keyId: key,
      values: values,
    );

    /// Local Update
    if (!scores.containsKey(key)) {
      scores[key] = {};
    }
    for (var entry in values.entries) {
      scores[key]![entry.key] = entry.value;
    }
    notifyListeners();

    return scores;
  }
}
