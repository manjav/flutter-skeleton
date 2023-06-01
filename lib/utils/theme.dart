import 'package:flutter/cupertino.dart';
import '../utils/device.dart';

class TColors {
  static const accent = Color(0xFFFF5D54);
  static const black = Color(0xFF000000);
  static const black80 = Color(0xCC000000);
  static const blue = Color(0xFF017AFA);
  static const cream = Color(0xFFF6E5D0);
  static const clay = Color(0xFFD29774);
  static const primary = Color(0xFFFFF8EE);
  static const primary90 = Color(0xFFF8E5D3);
  static const primary80 = Color(0xFFF3D0BA);
  static const primary70 = Color(0xFFE5B99F);
  static const primary30 = Color(0xFF88624B);
  static const primary20 = Color(0xFF77513A);
  static const primary10 = Color(0xFF66432E);
  static const gray = Color(0xFFA4A4A4);
  static const green = Color(0xFF12C14F);
  static const orange = Color(0xFFFF8B21);
  static const teal = Color(0xFF59AFC2);
  static const transparent = Color(0x00000000);
  static const white = Color(0xFFFFFFFF);
  static const white10 = Color(0x55FFFFFF);
}

class TStyles {
  static final tiny = _style(size: 10.d, weight: FontWeight.w100);
  static final small = _style(size: 13.4.d, weight: FontWeight.w300);
  static final medium = _style(size: 16.d, weight: FontWeight.w600);
  static final large = _style(size: 20.d, weight: FontWeight.w800);
  static final extraLarg = _style(size: 22.d, weight: FontWeight.w900);
  static final tinyInvert =
      _style(size: 10.d, weight: FontWeight.w100, color: TColors.primary);
  static final smallInvert =
      _style(size: 13.4.d, weight: FontWeight.normal, color: TColors.primary);
  static final mediumInvert =
      _style(size: 16.d, weight: FontWeight.normal, color: TColors.primary);
  static final largeInvert =
      _style(size: 20.4.d, weight: FontWeight.normal, color: TColors.primary);
}

TextStyle _style(
    {Color? color, double? size, String? font, FontWeight? weight}) {
  return TextStyle(
    fontSize: size,
    color: color ?? TColors.primary10,
    fontWeight: weight ?? FontWeight.bold,
    fontFamily: font ?? "GoogleFonts.secularOne().fontFamily",
  );
}

class Themes {
  static CupertinoThemeData? get darkData {
    var textTheme = CupertinoTextThemeData(
      primaryColor: TColors.primary,
      actionTextStyle: _style(weight: FontWeight.bold, size: 20.d),
      navLargeTitleTextStyle: _style(weight: FontWeight.bold, size: 22.d),
      navTitleTextStyle: _style(size: 16.d, weight: FontWeight.bold),
      navActionTextStyle: _style(weight: FontWeight.bold),
      tabLabelTextStyle: _style(weight: FontWeight.bold, size: 15.d),
      pickerTextStyle: _style(weight: FontWeight.bold, size: 15.d),
      dateTimePickerTextStyle:
          _style(size: 14.d, weight: FontWeight.bold, color: TColors.primary),
      textStyle: TStyles.small,
    );

    return CupertinoThemeData.raw(
        Brightness.light,
        TColors.primary70,
        TColors.primary10,
        textTheme,
        TColors.primary90,
        TColors.primary90,
        true);
  }
}
