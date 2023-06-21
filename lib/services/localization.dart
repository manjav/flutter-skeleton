import 'dart:convert';

import 'package:flutter/services.dart';

import '../../utils/ilogger.dart';
import 'iservices.dart';

class Localization extends IService {
  static Map<String, dynamic>? _sentences;
  var dir = TextDirection.ltr;
  var languageCode = "en";
  var isRTL = false;

  Localization();

  @override
  initialize({List<Object>? args}) async {
    dir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    _sentences = {};

    await rootBundle.loadString('texts/keys.json');
    await _getData('keys.json');
    await _getData('locale.json');
    super.initialize();
  }

  static _getData(String file) async {
    var data = await rootBundle.loadString('assets/texts/$file');
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
      ILogger.slog(this, "sentences = null");
      return '';
    }
    var result = Localization._sentences![key];
    if (result == null) {
      ILogger.slog(this, "$key not found!");
      return key;
    }
    if (args != null) {
      for (var arg in args) {
        result = result!.replaceFirst(RegExp(r'%s'), arg.toString());
      }
    }
    return result;
  }
}
