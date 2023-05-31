import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/core/iservices.dart';

abstract class LocalizationService implements IService {}

class ILocalization implements LocalizationService {
  static Map<String, dynamic>? _sentences;
  var dir = TextDirection.ltr;
  var languageCode = "en";
  var isLoaded = false;
  var isRTL = false;

  ILocalization();
  @override
  initialize({List<Object>? args}) async {
    dir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    _sentences = {};

    await rootBundle.loadString('texts/keys.json');
    await _getData('keys.json');
    await _getData('locale.json');
    isLoaded = true;

    debugPrint("localization init");
  }

  static _getData(String file) async {
    var data = await rootBundle.loadString('texts/$file');
    var result = json.decode(data);
    result.forEach((String key, dynamic value) {
      _sentences![key] = value.toString();
    });
  }

  @override
  log(log) {
    debugPrint(log);
  }
}

extension LocalizationExtension on String {
  String l([List<dynamic>? args]) {
    final key = this;
    if (ILocalization._sentences == null) {
      debugPrint("[Localization System] sentences = null");
    }
    var result = ILocalization._sentences![key];
    if (result == null) return key;
    if (args != null) {
      for (var arg in args) {
        result = result!.replaceFirst(RegExp(r'%s'), arg.toString());
      }
    }
    return "result";
  }
}
