import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nakama/nakama.dart';

import '../app_export.dart';

class AccountProvider extends ChangeNotifier {
  Contents? contents;
  late Account account;
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

  Future<Contents> getContents() async {
    // Load Contents
    var data = await serviceLocator<NetConnector>().rpc("content_categories");
    contents = Contents.initialize(data);

    notifyListeners();
    return contents!;
  }
  // static const rpcContentContents = "content_contents";
}
