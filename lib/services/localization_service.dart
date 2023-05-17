import 'dart:ui';

abstract class ILocalization {
  load();
}

class Localization implements ILocalization {
  static Map<String, dynamic>? _sentences;
  var dir = TextDirection.ltr;
  var languageCode = "en";
  var isLoaded = false;
  var isRTL = false;

  Localization();

  Future<void> load() async {
    // dir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    // _sentences = {};
    // await _getData('keys.json');
    // await _getData('locale.json');
    // isLoaded = true;
    // // notifyListeners();
  }

  // static _getData(String file) async {
  //   var data = await rootBundle.loadString('texts/$file');
  //   var result = json.decode(data);
  //   result.forEach((String key, dynamic value) {
  //     _sentences![key] = value.toString();
  //   });
  // }
}
