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
  final Map<String, FlashCard> leitner = {};
  bool get isTester => Pref.username.getString().startsWith("test_");

  void initialize(dynamic account) {
    this.account = account;
    Pref.username.setString(this.account.user.username ?? "");
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
            String video = list[i][Localization.targetLanguage];
            group.parent!.iconUrl = video;
            group.parent!.parent!.iconUrl = video.split("embed/")[1];
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
    bool onlyGreathers = false,
  }) async {
    await serviceLocator<NetConnector>().rpc("account_storage_set", params: {
      "collectionId": collectionId,
      "onlyGreathers": true,
      "keyId": keyId,
      "values": values,
    });
  }

  Future<Map<String, Map<String, dynamic>>> loadScores() async {
    scores = await serviceLocator<NetConnector>().readStorage(
      "scores_${metadata["targetLanguage"]}",
      userId: account.user.id,
    );
    notifyListeners();
    return scores;
  }

  Future<Map<String, Map<String, dynamic>>> saveScore(
    String key,
    Map<String, dynamic> values,
  ) async {
    /// Local Update
    var needUpdate = false;
    if (!scores.containsKey(key)) {
      scores[key] = {};
    }
    for (var entry in values.entries) {
      if (entry.value is num && (scores[key]![entry.key] ?? 0) < entry.value) {
        scores[key]![entry.key] = entry.value;
        needUpdate = true;
      }
    }
    if (needUpdate) {
      /// Send to Server
      writeStorage(
        collectionId: "scores_${metadata["targetLanguage"]}",
        onlyGreathers: true,
        keyId: key,
        values: values,
      );

      notifyListeners();
    }
    return scores;
  }

  Future<Map<String, FlashCard>> loadLeitner() async {
    Map<String, Map> result = await serviceLocator<NetConnector>().readStorage(
      "leitner",
      userId: account.user.id,
    );
    leitner.clear();
    for (var entry in result.entries) {
      final card = entry.value;
      _addToLeitner(
        card["id"]!,
        card["expected"],
        lastStep: card["step"],
        lastScore: card["score"],
        lastAnswer: card["answer"],
        createTime: card["createTime"],
        updateDate: card["updateDate"],
      );
    }
    notifyListeners();
    return leitner;
  }

  Future<FlashCard> addToLeitner(
    String id,
    String expectedAnswer, {
    int step = 0,
    int lastScore = 0,
    String? lastAnswer,
  }) async {
    var lastStep = leitner.containsKey(id) ? leitner[id]!.lastStep : 0;
    final card = _addToLeitner(
      id,
      expectedAnswer,
      lastStep: lastStep + step,
      lastScore: lastScore,
      lastAnswer: lastAnswer,
    );
    writeStorage(
      keyId: id,
      collectionId: "leitner",
      values: card.toMap(),
    );
    return card;
  }

  FlashCard _addToLeitner(
    String id,
    String expectedAnswer, {
    int lastStep = 0,
    String? lastAnswer,
    int lastScore = 0,
    DateTime? createTime,
    DateTime? updateDate,
  }) {
    if (!leitner.containsKey(id)) {
      leitner[id] = FlashCard(id, expectedAnswer, createTime ?? DateTime.now());
    }
    leitner[id]!.update(
      lastScore: lastScore,
      lastAnswer: lastAnswer,
      lastStep: lastStep,
      updateDate: updateDate,
    );
    return leitner[id]!;
  }
}

class FlashCard {
  final String id;
  final String expectedAnswer;
  final DateTime createTime;
  String? lastAnswer;
  DateTime? updateDate;
  int lastScore = 0, lastStep = 0;
  FlashCard(this.id, this.expectedAnswer, this.createTime);
  void update({
    int lastStep = 0,
    int lastScore = 0,
    String? lastAnswer,
    DateTime? updateDate,
  }) {
    this.lastStep = lastStep.min(0);
    this.lastScore = lastScore;
    this.lastAnswer = lastAnswer;
    this.updateDate = updateDate ?? DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "step": lastStep,
      "score": lastScore,
      "answer": lastAnswer,
      "expected": expectedAnswer,
    };
  }
}
