import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Localization {
  static Map<String, dynamic>? _sentences;
  var dir = TextDirection.ltr;
  var languageCode = "en";
  var isLoaded = false;
  var isRTL = false;

  Localization();

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
}

extension LocalizationExtension on String {
  String l([List<dynamic>? args]) {
    final key = this;
    if (Localization._sentences == null) {
      debugPrint("[Localization System] sentences = null");
    }
    var result = Localization._sentences![key];
    if (result == null) return key;
    if (args != null) {
      for (var arg in args) {
        result = result!.replaceFirst(RegExp(r'%s'), arg.toString());
      }
    }
    return "result";
  }
}
