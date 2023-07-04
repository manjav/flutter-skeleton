// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_skeleton/services/prefs.dart';
import 'package:http/http.dart' as http;

import '../../data/core/account.dart';
import '../../data/core/result.dart';
import '../../services/localization.dart';
import '../../utils/utils.dart';
import '../../view/widgets/loaderwidget.dart';
import '../deviceinfo.dart';
import '../iservices.dart';

abstract class IConnection extends IService {
  final response = NetResponse();

  @protected
  Future<void> loadConfigs();

  @protected
  Future<Result<Account>> loadAccount();

  @protected
  void updateResponse(LoadingState state, String message);

  @protected
  Future<Result<T>> rpc<T>(RpcId id, {Map<String, dynamic>? params});
}

class HttpConnection extends IConnection {
  static String baseURL = '';

  @override
  initialize({List<Object>? args}) async {
    await loadConfigs();
    var playerData = await loadAccount();
    updateResponse(LoadingState.connect, "Account ${'user'} connected.");
    super.initialize();
    return playerData;
  }

  // Load the Config file
  @override
  loadConfigs() async {
    try {
      final response = await http
          .get(Uri.parse('https://8ball.turnedondigital.com/fc/configs.json'));
      if (response.statusCode == 200) {
        var config = json.decode(response.body);
        baseURL = config['server'];
        LoaderWidget.baseURL = config['assetsServer'];
        LoaderWidget.hashMap = Map.castFrom(config['files']);
      } else {
        throw Exception('Failed to load config file');
      }
    } catch (e) {
      updateResponse(LoadingState.disconnect, e.toString());
    }
    log("Config loaded.");
  }

  // Connect to server
  @override
  Future<Result<Account>> loadAccount() async {
    var params = <String, dynamic>{
      ParamName.udid.name:
          '111eab5fa6eb7de12222a71616812f5f1d184741', //DeviceInfo.adId,
      ParamName.device_name.name: DeviceInfo.model,
      ParamName.game_version.name: 'app_version'.l(),
      ParamName.os_type.name: 1,
      ParamName.os_version.name: DeviceInfo.osVersion,
      ParamName.model.name: DeviceInfo.model,
      ParamName.store_type.name: "bazar",
      ParamName.restore_key.name: "keep3oil11",
      ParamName.name.name: "ArMaN"
    };
    var result =
        await rpc<Map<String, dynamic>>(RpcId.playerLoad, params: params);
    updateResponse(LoadingState.connect, "connected.");
    return Result<Account>(
        result.statusCode, "Account loading complete.", Account(result.data));
  }

  @override
  Future<Result<T>> rpc<T>(RpcId id, {Map? params}) async {
    params = params ?? {};
    try {
      final headers = _getDefaultHeader();
      var data = {};
        // var json =
        //     '{"game_version":"","device_name":"Ali MacBook Pro","os_version":"13.0.0","model":"KFJWI","udid":"e6ac281eae92abd4581116b380da33a8","store_type":"parsian","os_type":2}';
        var json = jsonEncode(params);
        log(json);
        data = id.needsEncryption ? {'edata': json.xorEncrypt()} : params;
        log(json.xorEncrypt());
      final url = Uri.parse('$baseURL/${id.value}');
      http.Response response;
      if (id.requestType == HttpRequestType.get) {
        response = await http.get(url, headers: headers);
      } else {
        response = await http.post(url, headers: headers, body: data);
      }
      final status = response.statusCode;
      if (status != 200) {
        throw Exception('http.post error: statusCode= $status');
      }

      _proccessResponseHeaders(response.headers);
      log(response.body);
      var body =
          id.needsEncryption ? response.body.xorDecrypt() : response.body;
      log(body);

      var responseData = jsonDecode(body);
      if (!responseData['status']) {
        var statusCode = (responseData['data']['code'] as int).toStatus();
        return Result<T>(statusCode, '', responseData['data'] as T?);
      }

      return Result<T>(StatusCode.C0_SUCCESS, '', responseData['data'] as T);
    } catch (e) {
      var error = '$e'.split('statusCode= ')[1].split(",")[0];
      if (error == "UNAUTHENTICATED" ||
          error == "UNAVAILABLE" ||
          error == "NOT_FOUND" ||
          error == "INTERNAL") {
        error = 'error_${error.toLowerCase()}';
      } else {
        error = "RPC: ${id.name} Error: $e";
      }
      updateResponse(LoadingState.error, error);
      return Result(StatusCode.C250_UNKNOWN_ERROR, "error", null);
    }
  }

  @override
  void updateResponse(LoadingState state, String message) {
    response.state = state;
    response.message = message;
    log("update response => ${state.name} - $message");
  }

  void _proccessResponseHeaders(Map<String, String> header) {
    if (header.containsKey('set-cookie')) {
      Pref.cookies.setString(header["set-cookie"]!);
    }
  }

  Map<String, String>? _getDefaultHeader(
      {Map<String, String>? headers, bool showLogs = true}) {
    if (!Platform.isAndroid && !Platform.isWindows /*&& buildType!="debug"*/) {
      return null;
    }
    if (showLogs) log("getting default headers");
    headers = headers ?? {};

    headers["Content-Type"] = "application/x-www-form-urlencoded";
    var cookies = Pref.cookies.getString();
    if (cookies.isNotEmpty) {
      headers["Cookie"] = cookies;
      }
    return headers;
  }
}

enum LoadingState { loading, disconnect, connect, complete, error }

class NetResponse {
  var state = LoadingState.loading;
  var message = "";

  @override
  String toString() {
    return '[state:$state, message:$message]';
  }
}

enum ParamName {
  // Player laod
  device_name,
  game_version,
  model,
  name,
  os_type,
  os_version,
  restore_key,
  store_type,
  udid,
}

enum RpcId {
  scout,
  playerLoad,
// Files
  tutorialExport,
  tutorialLangEnExport,
  tutorialLangFaExport,
  comboExport,
  comboLangEnExport,
  comboLangFaExport,
// Hero APIs
  heroItemsExport,
  heroItemsLangEnExport,
  heroItemsLangFaExport,
  buyHeroItem,
  setHeroItems,
  fruitLangFaExport,
  fruitLangEnExport,
  imageStorageAPI_ImageStorage,
  cardsExport,
  captcha,
  forgotPassword,
  getVCBalance,
}

extension RpcIdEx on RpcId {
  String get value {
    return switch (this) {
      RpcId.scout => "battle/scout",
      RpcId.playerLoad => "player/load",
      RpcId.tutorialExport => "metadata/TutorialData.json",
      RpcId.tutorialLangEnExport => "i18n/en-US/Tutorial.json",
      RpcId.tutorialLangFaExport => "i18n/fa-IR/Tutorial.json",
      RpcId.comboExport => "metadata/CardComboData.json",
      RpcId.comboLangEnExport => "i18n/en-US/CardComboLanguage.json",
      RpcId.comboLangFaExport => "i18n/fa-IR/CardComboLanguage.json",
      RpcId.heroItemsExport => "cards/heroitemsjsonexport",
      RpcId.heroItemsLangEnExport => "i18n/en-US/BaseHeroItemsLanguage.json",
      RpcId.heroItemsLangFaExport => "i18n/fa-IR/BaseHeroItemsLanguage.json",
      RpcId.buyHeroItem => "store/buyheroitem",
      RpcId.setHeroItems => "cards/equipheroitems",
      RpcId.fruitLangFaExport => "i18n/fa-IR/BaseFruitLanguage.json",
      RpcId.fruitLangEnExport => "i18n/en-US/BaseFruitLanguage.json",
      RpcId.imageStorageAPI_ImageStorage => "cardpool/",
      RpcId.cardsExport => "cards/cardsjsonexport",
      RpcId.captcha => "bot/getcaptcha",
      RpcId.forgotPassword => "user/iforgot",
      RpcId.getVCBalance => "user/getvcbalance/client/iOS/"
    };
  }

  bool get needsEncryption {
    return switch (this) {
      _ => true,
    };
  }

  HttpRequestType get requestType {
    return switch (this) {
      RpcId.tutorialExport ||
      RpcId.tutorialLangEnExport ||
      RpcId.tutorialLangFaExport ||
      RpcId.comboExport ||
      RpcId.comboLangEnExport ||
      RpcId.comboLangFaExport ||
      RpcId.heroItemsExport ||
      RpcId.heroItemsLangEnExport ||
      RpcId.heroItemsLangFaExport ||
      RpcId.buyHeroItem ||
      RpcId.setHeroItems ||
      RpcId.fruitLangFaExport ||
      RpcId.fruitLangEnExport ||
      RpcId.imageStorageAPI_ImageStorage ||
      RpcId.cardsExport ||
      RpcId.captcha ||
      RpcId.forgotPassword ||
      RpcId.getVCBalance =>
        HttpRequestType.get,
      _ => HttpRequestType.post,
    };
  }
}

enum HttpRequestType { get, post }
