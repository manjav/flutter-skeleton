import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_skeleton/services/core/iservices.dart';

class LocalizationService implements IService {
  static Map<String, dynamic>? _sentences;
  var dir = TextDirection.ltr;
  var languageCode = "en";
  var isLoaded = false;
  var isRTL = false;

  LocalizationService();
  @override
  initialize({List<Object>? args}) async {
    dir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    _sentences = {};

    await rootBundle.loadString('texts/keys.json');
    await _getData('keys.json');
    await _getData('locale.json');
    isLoaded = true;
  }

  static _getData(String file) async {
    var data = await rootBundle.loadString('texts/$file');
    var result = json.decode(data);
    result.forEach((String key, dynamic value) {
      _sentences![key] = value.toString();
    });
    print(result);
  }

  @override
  log(log) {
    debugPrint(log);
  }
}

extension LocalizationExtension on String {
  String l([List<dynamic>? args]) {
    final key = this;
    if (LocalizationService._sentences == null) {
      debugPrint("[Localization System] sentences = null");
    }
    var result = LocalizationService._sentences![key];
    if (result == null) return key;
    if (args != null) {
      for (var arg in args) {
        result = result!.replaceFirst(RegExp(r'%s'), arg.toString());
      }
    }
    return "result";
  }
}
