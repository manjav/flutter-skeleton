import 'package:flutter/material.dart';

import '../../app_export.dart';

class TColors {
  static const accent = Color(0xFFFF5D54);
  static const black = Color(0xFF000000);
  static const black80 = Color(0xCC000000);
  static const black25 = Color(0x40000000);
  static const blue = Color(0xFF017AFA);
  static const cream = Color(0xFFF6E5D0);
  static const cream15 = Color(0x26F9E4D9);
  static const clay = Color(0xFFD29774);
  static const cyan = Color(0xFF3FC1B9);
  static const primary = Color(0xFFFFF8EE);
  static const primary90 = Color(0xFFF8E5D3);
  static const primary80 = Color(0xFFF3D0BA);
  static const primary70 = Color(0xFFE5B99F);
  static const primary50 = Color(0xFFEF9D6A);
  static const primary30 = Color(0xFF88624B);
  static const primary20 = Color(0xFF572018);
  static const primary10 = Color(0xFF572018);
  static const gray = Color(0xFFA4A4A4);
  static const green = Color(0xFF82EE24);
  static const green40 = Color(0x660DAB4F);
  static const orange = Color(0xFFFF8B21);
  static const teal = Color(0xFF59AFC2);
  static const transparent = Color(0x00000000);
  static const white = Color(0xFFFFFFFF);
  static const white30 = Color(0x55FFFFFF);
  static const white50 = Color(0x88FFFFFF);
  static const red = Color(0xFFEE3E3E);
  static const red20 = Color(0x33EE3E3E);
  static const linearBlue = LinearGradient(
    colors: [Color(0xff23C9EE), Color(0xff3293C7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const linearGold = LinearGradient(
    colors: [Color(0xffFFFF2F), Color(0xffF9C31C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class TStyles {
  static TextStyle tiny = _style();
  static TextStyle small = _style();
  static TextStyle medium = _style();
  static TextStyle large = _style();
  static TextStyle big = _style();
  static TextStyle tinyInvert = _style();
  static TextStyle smallInvert = _style();
  static TextStyle mediumInvert = _style();
  static TextStyle largeInvert = _style();
}

extension Autosize on TextStyle {
  TextStyle autoSize(int length, int defaultLength, double size) => copyWith(
      fontSize: (defaultLength / length * size).clamp(size * 0.4, size));
}

TextStyle _style({Color? color, double? size, FontWeight? weight}) {
  return TextStyle(
    fontSize: size,
    color: color ?? TColors.primary10,
    fontWeight: weight ?? FontWeight.bold,
    fontFamily: "primary_font",
  );
}

class Themes {
  static void preInitialize() {
    TStyles.tiny = _style(size: 22.d, weight: FontWeight.w100);
    TStyles.small = _style(size: 30.d, weight: FontWeight.w300);
    TStyles.medium = _style(size: 38.d, weight: FontWeight.w600);
    TStyles.large = _style(size: 52.d, weight: FontWeight.w800);
    TStyles.big = _style(size: 72.d, weight: FontWeight.w900);
    TStyles.tinyInvert =
        _style(size: 22.d, weight: FontWeight.w100, color: TColors.primary90);
    TStyles.smallInvert = _style(
        size: 30.4.d, weight: FontWeight.normal, color: TColors.primary90);
    TStyles.mediumInvert =
        _style(size: 40.d, weight: FontWeight.normal, color: TColors.primary90);
    TStyles.largeInvert =
        _style(size: 52.d, weight: FontWeight.normal, color: TColors.primary90);
  }

  static ThemeData? get darkData {
    var textTheme = TextTheme(
      bodySmall: TStyles.small,
      bodyMedium: TStyles.medium,
      bodyLarge: TStyles.large,
      //   primaryColor: TColors.primary,
      //   actionTextStyle: _style(weight: FontWeight.bold, size: 20.d),
      //   navLargeTitleTextStyle: _style(weight: FontWeight.bold, size: 22.d),
      //   navTitleTextStyle: _style(size: 16.d, weight: FontWeight.bold),
      //   navActionTextStyle: _style(weight: FontWeight.bold),
      //   tabLabelTextStyle: _style(weight: FontWeight.bold, size: 15.d),
      //   pickerTextStyle: _style(weight: FontWeight.bold, size: 15.d),
      //   dateTimePickerTextStyle:
      //       _style(size: 14.d, weight: FontWeight.bold, color: TColors.primary),
      //   textStyle: TStyles.small,
    );

    return ThemeData(
      colorScheme: const ColorScheme.dark(
          background: TColors.black,
          primary: TColors.primary30,
          outline: TColors.primary70),
      brightness: Brightness.dark,
      textTheme: textTheme,
      useMaterial3: true,
    );
  }
}
