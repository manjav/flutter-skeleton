import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:intl/intl.dart' as intl;

import '../export.dart';

class Localization extends IService {
  static var locales = const [Locale("en"), Locale("fa")];
  static Map<String, dynamic>? _sentences;
  static String languageCode = "en";
  static TextDirection dir = TextDirection.ltr;
  static TextDirection textDirection = TextDirection.ltr;
  static bool isRTL = false;

  Localization();

  get columnAlign => isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  get rowAlign => isRTL ? MainAxisAlignment.end : MainAxisAlignment.start;

  @override
  initialize({List<Object>? args}) async {
    var locale = Localizations.localeOf(args![0] as BuildContext);
    languageCode = locale.languageCode;
    // isRTL = languageCode == "fa" || languageCode == "ar";
    // dir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    textDirection =
        languageCode == "fa" ? TextDirection.rtl : TextDirection.ltr;
    _sentences = {};
    await _getData("keys.json");
    await _getData("$languageCode.json");
    super.initialize();
  }

  changeLocal(Locale locale) async {
    languageCode = locale.languageCode;
    textDirection =
        languageCode == "fa" ? TextDirection.rtl : TextDirection.ltr;
    _sentences = {};
    await _getData("keys.json");
    await _getData("$languageCode.json");
    super.initialize();
  }

  static _getData(String file) async {
    var data = await rootBundle.loadString("assets/texts/$file");
    var result = json.decode(data);
    result.forEach((String key, dynamic value) {
      _sentences![key] = value.toString();
    });
  }

  static String convert(String input, {bool force = false}) {
    if (!Localization.isRTL && !force) return input;
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

  String convert() => this;
}

extension LocalizationIntExtension on int {
  String convert() => toString();

  String getFormattedPrice() {
    final storeId = FlavorConfig.instance.variables["storeId"];
    final formatter = intl.NumberFormat('###,###,###');
    if (["1", "3", "6", "7"].contains(storeId)) {
      return formatter.format('\$$this');
    }
    return '${formatter.format(this * 10)} ريال';
  }
}
