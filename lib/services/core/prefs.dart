import 'package:shared_preferences/shared_preferences.dart';

class Prefs
//NOTE services has been deleted
// extends BaseService
{
  static SharedPreferences? _instance;
  static var tutorStep = 0;
  static bool get inTutorial => tutorStep < TutorSteps.fine.value;
  Prefs(
      // super.services
      );

  Future<void> init({Function? onInit}) async {
    _instance = await SharedPreferences.getInstance();
    if (Pref.visitCount.getInt() <= 0) {
      setBool("settings_sfx", true);
      setBool("settings_music", true);
    }
    Pref.visitCount.increase(1);
    tutorStep = Pref.tutorStep.getInt();
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
  String get name {
    switch (this) {
      case Pref.testVersion:
        return "testVersion";
      case Pref.visitCount:
        return "visitCount";
      case Pref.tutorStep:
        return "tutorStep";
    }
  }

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
  int get value {
    switch (this) {
      case TutorSteps.welcome:
        return 0;
      case TutorSteps.exploreFirst:
        return 1;
      case TutorSteps.exploreSecond:
        return 2;
      case TutorSteps.mergeWelcome:
        return 10;
      case TutorSteps.mergeFirst:
        return 11;
      case TutorSteps.mergeSecond:
        return 12;
      case TutorSteps.mergeOffer:
        return 13;
      case TutorSteps.mergeFine:
        return 14;
      case TutorSteps.orderTap:
        return 20;
      case TutorSteps.orderFill:
        return 21;
      case TutorSteps.fine:
        return 30;
    }
  }

  void commit([bool force = false]) {
    if (!force && value <= Prefs.tutorStep) return;
    if (value % 10 == 0) {
      Pref.tutorStep.setInt(value);
    }
    Prefs.tutorStep = value;
  }
}
