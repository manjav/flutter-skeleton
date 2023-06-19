import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:xor_cipher/xor_cipher.dart';

import '../services/localization.dart';
import '../services/deviceinfo.dart';

extension IntExt on int {
  static final _formatter = NumberFormat('###,###,###');
  String format() {
    return _formatter.format(this);
  }

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

extension StringExt on String {
  String toPascalCase() {
    return substring(0, 1).toUpperCase() + substring(1).toLowerCase();
  }

  String xorEncrypt({String? secret}) {
    var secretKey = secret ?? _getDefaultSecret();
    final encrypted = XOR.encrypt(this, secretKey, urlEncode: false);
    var encodeddd = encrypted;
    return encodeddd.replaceAll('-', '+');
  }

  String xorDecrypt({String? secret}) {
    var secretKey = secret ?? _getDefaultSecret();
    return XOR.decrypt(this, secretKey, urlDecode: false);
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
}

class Asset {
  static const String prefix = "";
}

class SVG {
  static SvgPicture show(
    String name, {
    double? width,
    double? height,
    Color? color,
  }) {
    return SvgPicture.asset("images/${Asset.prefix}$name.svg",
        width: width,
        height: height,
        colorFilter:
            color == null ? null : ColorFilter.mode(color, BlendMode.srcIn));
  }
}

class Utils {
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();
  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static Future<Offset> scrollToItem(GlobalKey key, ScrollController controller,
      {double marginTop = 0,
      double marginBottom = 0,
      int time = 200,
      int direction = 1}) async {
    var box = key.currentContext?.findRenderObject() as RenderBox;
    var position = box.localToGlobal(Offset.zero); //this is global position
    var duration = Duration(milliseconds: time);
    const curve = Curves.ease;
    final top = position.dy - marginTop;
    if (top < 0) {
      position = position.translate(0, -top);
      await controller.animateTo(controller.position.pixels + top * direction,
          duration: duration, curve: curve);
    }
    final bottom = DeviceInfo.size.height - position.dy - marginBottom;
    if (bottom < 0) {
      position = position.translate(0, bottom);
      await controller.animateTo(
          controller.position.pixels - bottom * direction,
          duration: duration,
          curve: curve);
    }
    return position;
  }

  static const tz2flag = {
    "Africa/Abidjan": "ci",
    "Africa/Accra": "gh",
    "Africa/Addis_Ababa": "et",
    "Africa/Algiers": "dz",
    "Africa/Asmara": "er",
    "Africa/Asmera": "er",
    "Africa/Bamako": "ml",
    "Africa/Bangui": "cf",
    "Africa/Banjul": "gm",
    "Africa/Bissau": "gw",
    "Africa/Blantyre": "mw",
    "Africa/Brazzaville": "cg",
    "Africa/Bujumbura": "bi",
    "Africa/Cairo": "eg",
    "Africa/Casablanca": "ma",
    "Africa/Ceuta": "es",
    "Africa/Conakry": "gn",
    "Africa/Dakar": "sn",
    "Africa/Dar_es_Salaam": "tz",
    "Africa/Djibouti": "dj",
    "Africa/Douala": "cm",
    "Africa/El_Aaiun": "eh",
    "Africa/Freetown": "sl",
    "Africa/Gaborone": "bw",
    "Africa/Harare": "zw",
    "Africa/Johannesburg": "za",
    "Africa/Juba": "ss",
    "Africa/Kampala": "ug",
    "Africa/Khartoum": "sd",
    "Africa/Kigali": "rw",
    "Africa/Kinshasa": "cd",
    "Africa/Lagos": "ng",
    "Africa/Libreville": "ga",
    "Africa/Lome": "tg",
    "Africa/Luanda": "ao",
    "Africa/Lubumbashi": "cd",
    "Africa/Lusaka": "zm",
    "Africa/Malabo": "gq",
    "Africa/Maputo": "mz",
    "Africa/Maseru": "ls",
    "Africa/Mbabane": "sz",
    "Africa/Mogadishu": "so",
    "Africa/Monrovia": "lr",
    "Africa/Nairobi": "ke",
    "Africa/Ndjamena": "td",
    "Africa/Niamey": "ne",
    "Africa/Nouakchott": "mr",
    "Africa/Ouagadougou": "bf",
    "Africa/Porto-Novo": "bj",
    "Africa/Sao_Tome": "st",
    "Africa/Timbuktu": "ml",
    "Africa/Tripoli": "ly",
    "Africa/Tunis": "tn",
    "Africa/Windhoek": "na",
    "America/Adak": "us",
    "America/Anchorage": "us",
    "America/Anguilla": "ai",
    "America/Antigua": "ag",
    "America/Araguaina": "br",
    "America/Argentina/Buenos_Aires": "ar",
    "America/Argentina/Catamarca": "ar",
    "America/Argentina/Cordoba": "ar",
    "America/Argentina/Jujuy": "ar",
    "America/Argentina/La_Rioja": "ar",
    "America/Argentina/Mendoza": "ar",
    "America/Argentina/Rio_Gallegos": "ar",
    "America/Argentina/Salta": "ar",
    "America/Argentina/San_Juan": "ar",
    "America/Argentina/San_Luis": "ar",
    "America/Argentina/Tucuman": "ar",
    "America/Argentina/Ushuaia": "ar",
    "America/Aruba": "aw",
    "America/Asuncion": "py",
    "America/Atikokan": "ca",
    "America/Bahia": "br",
    "America/Bahia_Banderas": "mx",
    "America/Barbados": "bb",
    "America/Belem": "br",
    "America/Belize": "bz",
    "America/Blanc-Sablon": "ca",
    "America/Boa_Vista": "br",
    "America/Bogota": "co",
    "America/Boise": "us",
    "America/Cambridge_Bay": "ca",
    "America/Campo_Grande": "br",
    "America/Cancun": "mx",
    "America/Caracas": "ve",
    "America/Cayenne": "gf",
    "America/Cayman": "ky",
    "America/Chicago": "us",
    "America/Chihuahua": "mx",
    "America/Ciudad_Juarez": "mx",
    "America/Coral_Harbour": "ca",
    "America/Costa_Rica": "cr",
    "America/Creston": "ca",
    "America/Cuiaba": "br",
    "America/Curacao": "cw",
    "America/Danmarkshavn": "gl",
    "America/Dawson": "ca",
    "America/Dawson_Creek": "ca",
    "America/Denver": "us",
    "America/Detroit": "us",
    "America/Dominica": "dm",
    "America/Edmonton": "ca",
    "America/Eirunepe": "br",
    "America/El_Salvador": "sv",
    "America/Fort_Nelson": "ca",
    "America/Fortaleza": "br",
    "America/Glace_Bay": "ca",
    "America/Goose_Bay": "ca",
    "America/Grand_Turk": "tc",
    "America/Grenada": "gd",
    "America/Guadeloupe": "gp",
    "America/Guatemala": "gt",
    "America/Guayaquil": "ec",
    "America/Guyana": "gy",
    "America/Halifax": "ca",
    "America/Havana": "cu",
    "America/Hermosillo": "mx",
    "America/Indiana/Indianapolis": "us",
    "America/Indiana/Knox": "us",
    "America/Indiana/Marengo": "us",
    "America/Indiana/Petersburg": "us",
    "America/Indiana/Tell_City": "us",
    "America/Indiana/Vevay": "us",
    "America/Indiana/Vincennes": "us",
    "America/Indiana/Winamac": "us",
    "America/Inuvik": "ca",
    "America/Iqaluit": "ca",
    "America/Jamaica": "jm",
    "America/Juneau": "us",
    "America/Kentucky/Louisville": "us",
    "America/Kentucky/Monticello": "us",
    "America/Kralendijk": "bq",
    "America/La_Paz": "bo",
    "America/Lima": "pe",
    "America/Los_Angeles": "us",
    "America/Lower_Princes": "sx",
    "America/Maceio": "br",
    "America/Managua": "ni",
    "America/Manaus": "br",
    "America/Marigot": "mf",
    "America/Martinique": "mq",
    "America/Matamoros": "mx",
    "America/Mazatlan": "mx",
    "America/Menominee": "us",
    "America/Merida": "mx",
    "America/Metlakatla": "us",
    "America/Mexico_City": "mx",
    "America/Miquelon": "pm",
    "America/Moncton": "ca",
    "America/Monterrey": "mx",
    "America/Montevideo": "uy",
    "America/Montreal": "ca",
    "America/Montserrat": "ms",
    "America/Nassau": "bs",
    "America/New_York": "us",
    "America/Nipigon": "ca",
    "America/Nome": "us",
    "America/Noronha": "br",
    "America/North_Dakota/Beulah": "us",
    "America/North_Dakota/Center": "us",
    "America/North_Dakota/New_Salem": "us",
    "America/Nuuk": "gl",
    "America/Ojinaga": "mx",
    "America/Panama": "pa",
    "America/Paramaribo": "sr",
    "America/Phoenix": "us",
    "America/Port-au-Prince": "ht",
    "America/Port_of_Spain": "tt",
    "America/Porto_Velho": "br",
    "America/Puerto_Rico": "pr",
    "America/Punta_Arenas": "cl",
    "America/Rankin_Inlet": "ca",
    "America/Recife": "br",
    "America/Regina": "ca",
    "America/Resolute": "ca",
    "America/Rio_Branco": "br",
    "America/Santarem": "br",
    "America/Santiago": "cl",
    "America/Santo_Domingo": "do",
    "America/Sao_Paulo": "br",
    "America/Scoresbysund": "gl",
    "America/Sitka": "us",
    "America/St_Barthelemy": "bl",
    "America/St_Johns": "ca",
    "America/St_Kitts": "kn",
    "America/St_Lucia": "lc",
    "America/St_Thomas": "vi",
    "America/St_Vincent": "vc",
    "America/Swift_Current": "ca",
    "America/Tegucigalpa": "hn",
    "America/Thule": "gl",
    "America/Thunder_Bay": "ca",
    "America/Tijuana": "mx",
    "America/Toronto": "ca",
    "America/Tortola": "vg",
    "America/Vancouver": "ca",
    "America/Virgin": "vi",
    "America/Whitehorse": "ca",
    "America/Winnipeg": "ca",
    "America/Yakutat": "us",
    "America/Yellowknife": "ca",
    "Antarctica/Casey": "aq",
    "Antarctica/Davis": "aq",
    "Antarctica/DumontDUrville": "aq",
    "Antarctica/Macquarie": "au",
    "Antarctica/Mawson": "aq",
    "Antarctica/McMurdo": "aq",
    "Antarctica/Palmer": "aq",
    "Antarctica/Rothera": "aq",
    "Antarctica/South_Pole": "aq",
    "Antarctica/Syowa": "aq",
    "Antarctica/Troll": "aq",
    "Antarctica/Vostok": "aq",
    "Arctic/Longyearbyen": "sj",
    "Asia/Aden": "ye",
    "Asia/Almaty": "kz",
    "Asia/Amman": "jo",
    "Asia/Anadyr": "ru",
    "Asia/Aqtau": "kz",
    "Asia/Aqtobe": "kz",
    "Asia/Ashgabat": "tm",
    "Asia/Atyrau": "kz",
    "Asia/Baghdad": "iq",
    "Asia/Bahrain": "bh",
    "Asia/Baku": "az",
    "Asia/Bangkok": "th",
    "Asia/Barnaul": "ru",
    "Asia/Beirut": "lb",
    "Asia/Bishkek": "kg",
    "Asia/Brunei": "bn",
    "Asia/Chita": "ru",
    "Asia/Choibalsan": "mn",
    "Asia/Colombo": "lk",
    "Asia/Damascus": "sy",
    "Asia/Dhaka": "bd",
    "Asia/Dili": "tl",
    "Asia/Dubai": "ae",
    "Asia/Dushanbe": "tj",
    "Asia/Famagusta": "cy",
    "Asia/Gaza": "ps",
    "Asia/Hebron": "ps",
    "Asia/Ho_Chi_Minh": "vn",
    "Asia/Hong_Kong": "hk",
    "Asia/Hovd": "mn",
    "Asia/Irkutsk": "ru",
    "Asia/Jakarta": "id",
    "Asia/Jayapura": "id",
    "Asia/Jerusalem": "il",
    "Asia/Kabul": "af",
    "Asia/Kamchatka": "ru",
    "Asia/Karachi": "pk",
    "Asia/Kashgar": "cn",
    "Asia/Kathmandu": "np",
    "Asia/Khandyga": "ru",
    "Asia/Kolkata": "in",
    "Asia/Krasnoyarsk": "ru",
    "Asia/Kuala_Lumpur": "my",
    "Asia/Kuching": "my",
    "Asia/Kuwait": "kw",
    "Asia/Macau": "mo",
    "Asia/Magadan": "ru",
    "Asia/Makassar": "id",
    "Asia/Manila": "ph",
    "Asia/Muscat": "om",
    "Asia/Nicosia": "cy",
    "Asia/Novokuznetsk": "ru",
    "Asia/Novosibirsk": "ru",
    "Asia/Omsk": "ru",
    "Asia/Oral": "kz",
    "Asia/Phnom_Penh": "kh",
    "Asia/Pontianak": "id",
    "Asia/Pyongyang": "kp",
    "Asia/Qatar": "qa",
    "Asia/Qostanay": "kz",
    "Asia/Qyzylorda": "kz",
    "Asia/Rangoon": "mm",
    "Asia/Riyadh": "sa",
    "Asia/Sakhalin": "ru",
    "Asia/Samarkand": "uz",
    "Asia/Seoul": "kr",
    "Asia/Shanghai": "cn",
    "Asia/Singapore": "sg",
    "Asia/Srednekolymsk": "ru",
    "Asia/Taipei": "tw",
    "Asia/Tashkent": "uz",
    "Asia/Tbilisi": "ge",
    "Asia/Tehran": "ir",
    "Asia/Thimphu": "bt",
    "Asia/Tokyo": "jp",
    "Asia/Tomsk": "ru",
    "Asia/Ulaanbaatar": "mn",
    "Asia/Urumqi": "cn",
    "Asia/Ust-Nera": "ru",
    "Asia/Vientiane": "la",
    "Asia/Vladivostok": "ru",
    "Asia/Yakutsk": "ru",
    "Asia/Yangon": "mm",
    "Asia/Yekaterinburg": "ru",
    "Asia/Yerevan": "am",
    "Atlantic/Azores": "pt",
    "Atlantic/Bermuda": "bm",
    "Atlantic/Canary": "es",
    "Atlantic/Cape_Verde": "cv",
    "Atlantic/Faroe": "fo",
    "Atlantic/Jan_Mayen": "sj",
    "Atlantic/Madeira": "pt",
    "Atlantic/Reykjavik": "is",
    "Atlantic/South_Georgia": "gs",
    "Atlantic/St_Helena": "sh",
    "Atlantic/Stanley": "fk",
    "Australia/Adelaide": "au",
    "Australia/Brisbane": "au",
    "Australia/Broken_Hill": "au",
    "Australia/Darwin": "au",
    "Australia/Eucla": "au",
    "Australia/Hobart": "au",
    "Australia/Lindeman": "au",
    "Australia/Lord_Howe": "au",
    "Australia/Melbourne": "au",
    "Australia/Perth": "au",
    "Australia/Sydney": "au",
    "Canada/Eastern": "ca",
    "Europe/Amsterdam": "nl",
    "Europe/Andorra": "ad",
    "Europe/Astrakhan": "ru",
    "Europe/Athens": "gr",
    "Europe/Belfast": "gb",
    "Europe/Belgrade": "rs",
    "Europe/Berlin": "de",
    "Europe/Bratislava": "sk",
    "Europe/Brussels": "be",
    "Europe/Bucharest": "ro",
    "Europe/Budapest": "hu",
    "Europe/Busingen": "de",
    "Europe/Chisinau": "md",
    "Europe/Copenhagen": "dk",
    "Europe/Dublin": "ie",
    "Europe/Gibraltar": "gi",
    "Europe/Guernsey": "gg",
    "Europe/Helsinki": "fi",
    "Europe/Isle_of_Man": "im",
    "Europe/Istanbul": "tr",
    "Europe/Jersey": "je",
    "Europe/Kaliningrad": "ru",
    "Europe/Kirov": "ru",
    "Europe/Kyiv": "ua",
    "Europe/Lisbon": "pt",
    "Europe/Ljubljana": "si",
    "Europe/London": "gb",
    "Europe/Luxembourg": "lu",
    "Europe/Madrid": "es",
    "Europe/Malta": "mt",
    "Europe/Mariehamn": "ax",
    "Europe/Minsk": "by",
    "Europe/Monaco": "mc",
    "Europe/Moscow": "ru",
    "Europe/Oslo": "no",
    "Europe/Paris": "fr",
    "Europe/Podgorica": "me",
    "Europe/Prague": "cz",
    "Europe/Riga": "lv",
    "Europe/Rome": "it",
    "Europe/Samara": "ru",
    "Europe/San_Marino": "sm",
    "Europe/Sarajevo": "ba",
    "Europe/Saratov": "ru",
    "Europe/Simferopol": "ru",
    "Europe/Skopje": "mk",
    "Europe/Sofia": "bg",
    "Europe/Stockholm": "se",
    "Europe/Tallinn": "ee",
    "Europe/Tirane": "al",
    "Europe/Ulyanovsk": "ru",
    "Europe/Vaduz": "li",
    "Europe/Vatican": "va",
    "Europe/Vienna": "at",
    "Europe/Vilnius": "lt",
    "Europe/Volgograd": "ru",
    "Europe/Warsaw": "pl",
    "Europe/Zagreb": "hr",
    "Europe/Zurich": "ch",
    "Indian/Antananarivo": "mg",
    "Indian/Chagos": "io",
    "Indian/Christmas": "cx",
    "Indian/Cocos": "cc",
    "Indian/Comoro": "km",
    "Indian/Kerguelen": "tf",
    "Indian/Mahe": "sc",
    "Indian/Maldives": "mv",
    "Indian/Mauritius": "mu",
    "Indian/Mayotte": "yt",
    "Indian/Reunion": "re",
    "Pacific/Apia": "ws",
    "Pacific/Auckland": "nz",
    "Pacific/Bougainville": "pg",
    "Pacific/Chatham": "nz",
    "Pacific/Chuuk": "fm",
    "Pacific/Easter": "cl",
    "Pacific/Efate": "vu",
    "Pacific/Fakaofo": "tk",
    "Pacific/Fiji": "fj",
    "Pacific/Funafuti": "tv",
    "Pacific/Galapagos": "ec",
    "Pacific/Gambier": "pf",
    "Pacific/Guadalcanal": "sb",
    "Pacific/Guam": "gu",
    "Pacific/Honolulu": "us",
    "Pacific/Johnston": "um",
    "Pacific/Kanton": "ki",
    "Pacific/Kiritimati": "ki",
    "Pacific/Kosrae": "fm",
    "Pacific/Kwajalein": "mh",
    "Pacific/Majuro": "mh",
    "Pacific/Marquesas": "pf",
    "Pacific/Midway": "um",
    "Pacific/Nauru": "nr",
    "Pacific/Niue": "nu",
    "Pacific/Norfolk": "nf",
    "Pacific/Noumea": "nc",
    "Pacific/Pago_Pago": "as",
    "Pacific/Palau": "pw",
    "Pacific/Pitcairn": "pn",
    "Pacific/Pohnpei": "fm",
    "Pacific/Ponape": "fm",
    "Pacific/Port_Moresby": "pg",
    "Pacific/Rarotonga": "ck",
    "Pacific/Saipan": "mp",
    "Pacific/Samoa": "as",
    "Pacific/Tahiti": "pf",
    "Pacific/Tarawa": "ki",
    "Pacific/Tongatapu": "to",
    "Pacific/Truk": "fm",
    "Pacific/Wake": "um",
    "Pacific/Wallis": "wf",
    "Pacific/Yap": "fm",
    "US/Arizona": "us",
    "US/Hawaii": "us",
    "US/Samoa": "as"
  };
}

extension DateExt on DateTime {
  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();
  int get daysSinceEpoch =>
      (millisecondsSinceEpoch / (24 * 3600 * 1000)).round();
}
