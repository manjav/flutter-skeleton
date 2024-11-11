import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

import '../../app_export.dart';

class Localization extends IService {
  static var locales = const [Locale("en"), Locale("es"), Locale("fa")];
  static Map<String, dynamic>? _sentences;
  static String languageCode = "en";
  static String targetLanguage = "es";
  static TextDirection dir = TextDirection.ltr;
  static bool isRTLMode(String code) => code == "fa" || code == "ar";
  static bool isRTL = false;

  Localization();

  get columnAlign => isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  get rowAlign => isRTL ? MainAxisAlignment.end : MainAxisAlignment.start;

  Future<void> preInitialize() async {
    _sentences = {};
    var keys = await rootBundle.loadString("assets/texts/keys.json");
    await _getData(json.decode(keys));
  }

  @override
  initialize({List<Object>? args}) async {
    isRTL = isRTLMode(languageCode);
    dir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    var localizations = await serviceLocator<NetConnector>()
        .rpc("content_locales_get", params: {"nativeLanguage": languageCode});

    await _getData(localizations);
    super.initialize();
  }

  static _getData(Map result) async {
    for (var e in result.entries) {
      _sentences![e.key] = e.value.toString();
    }
  }

  static String convert(String input) {
    if (!Localization.isRTL) return input;
    return input
        .replaceAll('0', '٠')
        .replaceAll('1', '١')
        .replaceAll('2', '٢')
        .replaceAll('3', '٣')
        .replaceAll('4', '۴')
        .replaceAll('5', '۵')
        .replaceAll('6', '۶')
        .replaceAll('7', '٧')
        .replaceAll('8', '٨')
        .replaceAll('9', '٩');
  }

  static Pattern getLimits(String code) {
    if (isRTLMode(code)) return RegExp(r'^[\u0621-\u064A0-9 ]+$');
    return RegExp(r'^((?![\u0621-\u064A0-9 ]+).)*$');
  }
}

extension LocalizationExtension on String {
  String l([List<dynamic>? args]) {
    final key = this;
    if (Localization._sentences == null) {
      ILogger.slog(this, "sentences = null");
      return "";
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

  TextDirection getDirection() => intl.Bidi.detectRtlDirectionality(this)
      ? TextDirection.rtl
      : TextDirection.ltr;

  String convert() => Localization.convert(this);
}

extension LocalizationIntExtension on int {
  String convert() => Localization.convert(toString());
}

class DirText extends Text {
  DirText(super.text, {super.key, super.style, super.textAlign})
      : super(textDirection: text.getDirection());
}
