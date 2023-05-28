// import 'package:flutter/cupertino.dart';
// import 'package:google_fonts/google_fonts.dart';

// enum TColors {
//   accent,
//   black,
//   black80,
//   blue,
//   clay,
//   cream,
//   primary,
//   primary70,
//   primary90,
//   primary80,
//   primary10,
//   gray,
//   green,
//   orange,
//   teal,
//   transparent,
//   white,
//   white10,
// }

// const _colors = <TColors, Color>{
//   TColors.accent: Color(0xFFFF5D54),
//   TColors.black: Color(0xFF000000),
//   TColors.black80: Color(0xCC000000),
//   TColors.blue: Color(0xFF017AFA),
//   TColors.cream: Color(0xFFF6E5D0),
//   TColors.clay: Color(0xFFD29774),
//   TColors.primary: Color(0xFFFFF8EE),
//   TColors.primary90: Color(0xFFF8E5D3),
//   TColors.primary80: Color(0xFFF3D0BA),
//   TColors.primary70: Color(0xFFE5B99F),
//   TColors.primary10: Color(0xFF66432E),
//   TColors.gray: Color(0xFFA4A4A4),
//   TColors.green: Color(0xFF12C14F),
//   TColors.orange: Color(0xFFFF8B21),
//   TColors.teal: Color(0xFF59AFC2),
//   TColors.transparent: Color(0x00000000),
//   TColors.white: Color(0xFFFFFFFF),
//   TColors.white10: Color(0x55FFFFFF),
// };

// extension TColorsExt on TColors {
//   Color get value => _colors[this]!;
// }

// enum TStyles {
//   tiny,
//   small,
//   medium,
//   large,
//   extraLarg,
//   tinyInvert,
//   smallInvert,
//   mediumInvert,
//   largeInvert,
// }

// var _styles = <TStyles, TextStyle>{
//   TStyles.tiny: _style(size: 10.d, weight: FontWeight.w100),
//   TStyles.small: _style(size: 13.4.d, weight: FontWeight.w300),
//   TStyles.medium: _style(size: 16.d, weight: FontWeight.w400),
//   TStyles.large: _style(size: 20.d, weight: FontWeight.w700),
//   TStyles.extraLarg: _style(size: 22.d, weight: FontWeight.w900),
//   TStyles.tinyInvert:
//       _style(size: 10.d, weight: FontWeight.w100, color: TColors.primary),
//   TStyles.smallInvert:
//       _style(size: 13.4.d, weight: FontWeight.normal, color: TColors.primary),
//   TStyles.mediumInvert:
//       _style(size: 16.d, weight: FontWeight.normal, color: TColors.primary),
//   TStyles.largeInvert:
//       _style(size: 20.4.d, weight: FontWeight.normal, color: TColors.primary),
// };

// TextStyle _style(
//     {TColors? color, double? size, String? font, FontWeight? weight}) {
//   return TextStyle(
//     fontSize: size,
//     color: (color ?? TColors.primary10).value,
//     fontWeight: weight ?? FontWeight.bold,
//     fontFamily: font ?? GoogleFonts.secularOne().fontFamily,
//   );
// }

// extension TStyleExt on TStyles {
//   TextStyle get value => _styles[this]!;
// }

// class Themes {
//   static CupertinoThemeData? get darkData {
//     var textTheme = CupertinoTextThemeData(
//       primaryColor: TColors.primary.value,
//       actionTextStyle: _style(weight: FontWeight.bold, size: 20.d),
//       navLargeTitleTextStyle: _style(weight: FontWeight.bold, size: 22.d),
//       navTitleTextStyle: _style(size: 16.d, weight: FontWeight.bold),
//       navActionTextStyle: _style(weight: FontWeight.bold),
//       tabLabelTextStyle: _style(weight: FontWeight.bold, size: 15.d),
//       pickerTextStyle: _style(weight: FontWeight.bold, size: 15.d),
//       dateTimePickerTextStyle:
//           _style(size: 14.d, weight: FontWeight.bold, color: TColors.primary),
//       textStyle: TStyles.small.value,
//     );

//     return CupertinoThemeData.raw(
//         Brightness.light,
//         TColors.primary70.value,
//         TColors.primary10.value,
//         textTheme,
//         TColors.primary90.value,
//         TColors.primary90.value);
//   }
// }
