import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import '../../data/data.dart';
import '../skeleton.dart';

extension IntExtension on int {
  static final _separator = NumberFormat('###,###,###');

  String format() => _separator.format(this);
  static final _compactor = NumberFormat.compact();

  String compact() => _compactor.format(this);

  String toTime() {
    var t = (this / 1000).round();
    var s = t % 60;
    t -= s;
    var m = ((t % 3600) / 60).round();
    t -= m * 60;
    var h = (t / 3600).floor();
    var ss = s < 10 ? "0$s" : "$s";
    var ms = m < 10 ? "0$m" : "$m";
    var hs = h < 10 ? "0$h" : "$h";
    return "$hs : $ms : $ss";
  }

  String toRemainingTime({bool complete = false}) {
    if (this < 60) return "${this}s";

    var seconds = this % 60;
    var minutes = (this / 60).round();
    if (minutes < 60) {
      if (seconds > 0) {
        if (complete) {
          return "${minutes}m${seconds}s";
        }
        return "${minutes}m";
      }
      return "${minutes}m";
    }
    var hours = (minutes / 60).floor();
    minutes = minutes % 60;
    if (hours < 24) {
      if (minutes > 0) {
        if (complete) {
          return "${hours}h${minutes}m";
        }
        return "${hours}h";
      }
      return "${hours}h";
    }

    var days = (hours / 24).floor();
    hours = hours % 24;
    if (hours > 0) return "${days}d${hours}h";
    return "${days}d";
  }

  String toElapsedTime() {
    if (this < 300) return "ago_moments".l();

    var minutes = (this / 60).round();
    if (minutes < 60) return "ago_minutes".l([minutes]);

    var hours = (minutes / 60).floor();
    if (hours < 24) return "ago_hours".l([hours]);

    var days = (hours / 24).floor();
    if (days < 31) return "ago_days".l([days]);

    var months = (days / 30).floor();
    if (months < 13) return "ago_months".l([months]);

    return "ago_years".l([(months / 12).floor()]);
  }

  int min(int min) => this < min ? min : this;

  int max(int max) => this > max ? max : this;
}

extension StringExtension on String {
  String toPascalCase() {
    return substring(0, 1).toUpperCase() + substring(1).toLowerCase();
  }

  String xorEncrypt({String? secret}) {
    var secretKey = secret ?? _getDefaultSecret();
    var result = "";
    for (var i = 0; i < length; i++) {
      result += String.fromCharCode(
          codeUnitAt(i) ^ secretKey.codeUnitAt(i % secretKey.length));
    }
    return utf8.fuse(base64).encode(result);
  }

  String xorDecrypt({String? secret}) {
    var b64 = utf8.fuse(base64);
    try {
      return b64.decode(b64.decode(this).xorEncrypt(secret: secret));
    } catch (e) {
      throw SkeletonException(StatusCode.C901_ENCRYPTION_ERROR.value, "");
    }
  }

  String _getDefaultSecret() {
    var secretParts = [
      "",
      "288",
      "1343",
      "1055",
      "based",
      "ali",
      "antler",
      "faraz"
    ];
    return secretParts[5] +
        secretParts[2] +
        secretParts[7] +
        secretParts[3] +
        secretParts[6] +
        secretParts[1] +
        secretParts[4];
  }

  String truncate(int length, {String postfix = "..."}) =>
      "${substring(0, this.length.max(length))}$postfix";

  String getRandomChar([int len = 1]) {
    var r = Random().nextInt(length - len + 1);
    return substring(r, len);
  }
}

extension DateExtension on DateTime {
  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();

  int get daysSinceEpoch =>
      (millisecondsSinceEpoch / (24 * 3600 * 1000)).round();
}
