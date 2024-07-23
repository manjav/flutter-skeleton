import 'package:flutter/material.dart';

import '../../app_export.dart';

class TColors {
  static const primary = Color(0xFF19212A);
  static const primary90 = Color(0xFF223140);
  static const primary80 = Color(0xFF2E4154);
  static const primary70 = Color(0xFF3C5167);
  static const primary60 = Color(0xFF4E637C);
  static const primary50 = Color(0xFF617791);
  static const primary40 = Color(0xFF7A8FA9);
  static const primary30 = Color(0xFF92A6C0);
  static const primary20 = Color(0xFFADBFD6);
  static const primary10 = Color(0xFFCFCFCF);
  static const primary0 = Color(0xFFFFF9EF);
  static const error = Color(0xFFFF5D54);
  static const green = Color(0xFF01C593);
  static const black = Color(0xFF000000);
  static const black80 = Color(0xAA000000);
  static const blue = Color(0xFF4848FF);
  static const cream = Color(0xFFF6E5D0);
  static const clay = Color(0xFFD29774);
  static const cyan = Color(0xFF3FC1B9);
  static const gray = Color(0xFFA4A4A4);
  static const orange = Color(0xFFFF7F48);
  static const purpule = Color(0xFFDA48FF);
  static const teal = Color(0xFF59AFC2);
  static const transparent = Color(0x00000000);
  static const white = Color(0xFFFFFFFF);
  static const white30 = Color(0x55FFFFFF);
  static const white50 = Color(0x88FFFFFF);
  static const red = Color(0xFFF3543E);
}

class TStyles {
  static TextStyle tiny = _style();
  static TextStyle small = _style();
  static TextStyle medium = _style();
  static TextStyle large = _style();
  static TextStyle big = _style();
  static TextStyle huge = _style();
  static TextStyle tinyInvert = _style();
  static TextStyle smallInvert = _style();
  static TextStyle mediumInvert = _style();
  static TextStyle largeInvert = _style();
  static TextStyle bigInvert = _style();
}

extension Autosize on TextStyle {
  TextStyle autoSize(int length, int defaultLength, double size) => copyWith(
      fontSize: (defaultLength / length * size).clamp(size * 0.4, size));
}

TextStyle _style({Color? color, double? size, FontWeight? weight}) {
  return TextStyle(
    fontSize: size,
    color: color ?? TColors.primary70,
    fontWeight: weight ?? FontWeight.bold,
    fontFamily: "primary_font",
  );
}

class Themes {
  static void preInitialize() {
    TStyles.tiny = _style(size: 10.d, weight: FontWeight.w100);
    TStyles.small = _style(size: 14.d, weight: FontWeight.w300);
    TStyles.medium = _style(size: 16.d, weight: FontWeight.w400);
    TStyles.large = _style(size: 19.d, weight: FontWeight.w600);
    TStyles.big = _style(size: 22.d, weight: FontWeight.w700);
    TStyles.huge = _style(size: 32.d, weight: FontWeight.w800);
    TStyles.tinyInvert =
        _style(size: 10.d, weight: FontWeight.w100, color: TColors.primary0);
    TStyles.smallInvert =
        _style(size: 14.d, weight: FontWeight.w300, color: TColors.primary0);
    TStyles.mediumInvert =
        _style(size: 16.d, weight: FontWeight.w400, color: TColors.primary0);
    TStyles.largeInvert =
        _style(size: 19.d, weight: FontWeight.w600, color: TColors.primary0);
    TStyles.largeInvert =
        _style(size: 22.d, weight: FontWeight.w700, color: TColors.primary0);
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
      colorScheme: const ColorScheme.light(
          primary: TColors.primary, outline: TColors.primary70),
      brightness: Brightness.light,
      textTheme: textTheme,
      useMaterial3: true,
    );
  }
}
