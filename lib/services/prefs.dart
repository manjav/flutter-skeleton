import 'package:shared_preferences/shared_preferences.dart';

import 'core/iservices.dart';

class Prefs extends IService {
  static SharedPreferences? _instance;
  static var tutorStep = 0;
  static bool get inTutorial => tutorStep < TutorSteps.fine.value;

  @override
  initialize({List<Object>? args}) async {
    _instance = await SharedPreferences.getInstance();
    if (Pref.visitCount.getInt() <= 0) {
      setBool("settings_sfx", true);
      setBool("settings_music", true);
    }
    Pref.visitCount.increase(1);
    tutorStep = Pref.tutorStep.getInt();
    super.initialize();
  }

  static bool contains(String key) => _instance!.containsKey(key);

  static String getString(String key) => _instance!.getString(key) ?? "";
  static String setString(String key, String value) {
    _instance!.setString(key, value);
    return value;
  }

  static bool getBool(String key) => _instance!.getBool(key) ?? false;
  static bool setBool(String key, bool value) {
    _instance!.setBool(key, value);
    return value;
  }

  static int getInt(String key) => _instance!.getInt(key) ?? 0;
  static int setInt(String key, int value) {
    _instance!.setInt(key, value);
    return value;
  }

  static int increase(String key, int value) {
    if (value == 0) return 0;
    var newValue = getInt(key) + value;
    setInt(key, newValue);
    return newValue;
  }
}

enum Pref {
  testVersion,
  visitCount,
  tutorStep,
}

extension PrefExt on Pref {
  bool contains() => Prefs.contains(name);

  int setInt(int value) => Prefs.setInt(name, value);
  int getInt() => Prefs.getInt(name);
  int increase(int value) => Prefs.increase(name, value);

  String setString(String value) => Prefs.setString(name, value);
  String getString() => Prefs.getString(name);

  bool setBool(bool value) => Prefs.setBool(name, value);
  bool getBool() => Prefs.getBool(name);
}

enum TutorSteps {
  welcome,
  exploreFirst,
  exploreSecond,
  mergeWelcome,
  mergeFirst,
  mergeSecond,
  mergeOffer,
  mergeFine,
  orderTap,
  orderFill,
  fine,
}

extension PTutorStapsExt on TutorSteps {
  int get value => switch (this) {
        TutorSteps.welcome => 0,
        TutorSteps.exploreFirst => 1,
        TutorSteps.exploreSecond => 2,
        TutorSteps.mergeWelcome => 10,
        TutorSteps.mergeFirst => 11,
        TutorSteps.mergeSecond => 12,
        TutorSteps.mergeOffer => 13,
        TutorSteps.mergeFine => 14,
        TutorSteps.orderTap => 20,
        TutorSteps.orderFill => 21,
        TutorSteps.fine => 30
      };

  void commit([bool force = false]) {
    if (!force && value <= Prefs.tutorStep) return;
    if (value % 10 == 0) {
      Pref.tutorStep.setInt(value);
    }
    Prefs.tutorStep = value;
  }
}
