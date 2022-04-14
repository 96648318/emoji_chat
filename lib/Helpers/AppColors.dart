import 'package:flutter/material.dart' show Color, Colors;

import 'ConstData.dart';

class AppColors {

  static List<Color> waveColors = [
    const Color(0xff3b75c4),
    const Color(0xff457fce),
    const Color(0xff5089d8),
    const Color(0xff3b75c4),
    const Color(0xff2d66b5),
    main_color,
  ];

  static List<Color> waveColorsBlack = [
    const Color(0xff111111),
    const Color(0xff262626),
    const Color(0xff2f2f2f),
    const Color(0xff1c1c1c),
    const Color(0xff0d0d0e),
    const Color(0xff060607),
  ];

  static Color getCircularChartColor(index) {
    Color color = Colors.redAccent;
    if (index == 0) {
      color = const Color(0xffdf6967);
    } else if (index == 4) {
      color = const Color(0xff32cfee);
    } else if (index == 1) {
      color = const Color(0xff2ba7ff);
    } else if (index == 2) {
      color = const Color(0xfff9ac3a);
    } else if (index == 5) {
      color = const Color(0xffffd527);
    } else if (index == 6) {
      color = const Color(0xffe9e9e9);
    } else if (index == 3) {
      color = const Color(0xff34df91);
    }
    return color;
  }


  static const Color main_color =  Color(0xff215aa9);
  static Color light_main_color1 = const Color(0xff3c76c7);
  static Color light_main_color2 = const Color(0xff5b95e4);
  static Color ligh_accents = const Color(0xff9dbae0);
  static Color light_grey_color = const Color(0xffDDDDDD);
  static Color grey_color = const Color(0xff999999);
  static Color dark_grey_color = const Color(0xff444444);
  static Color white_color = const Color(0xffffffff);
  static Color black_color = const Color(0xFF000000);
  static Color black_color87 = const Color(0xDD000000);
  static Color black_color26 = const Color(0x42000000);
  static Color red_color = const Color(0xffff4c4c);
  static Color trend_line_color = const Color(0xffff6060);
  static Color yellow =ConstData.hexToColor("#f9b232");
  static Color LightYellow =ConstData.hexToColor("#ffdea3");
  static Color darkyellow =ConstData.hexToColor("#d99212");
  static Color red = ConstData.hexToColor("#bd1421");
  static Color Lightred = ConstData.hexToColor("#e2505b");
  static Color VeryLightRed = ConstData.hexToColor("#fff1f1");
  static Color VeryLightBlue = ConstData.hexToColor("#e0dcff");
  static Color walletBG = ConstData.hexToColor("#e6e2fd");
  static Color primary = ConstData.hexToColor("#FA8072");
  static Color lightprimary = ConstData.hexToColor("#FCB9A6FF");


  static Color visit_type_chemist = const Color(0xffd0c4ec);
  static Color visit_type_stockiest = const Color(0xffecf0d9);
  static Color visit_type_doctor_mcr = const Color(0xffceebe5);
  static Color visit_type_doctor_non_mcr = const Color(0xffeccece);

  static Color work_type_sunday = const Color(0xffffcdd2);
  static Color work_type_leave = const Color(0xffe1bee7);
  static Color work_type_holiday = const Color(0xffb2dfdb);

  static Color light_blue_card_background = const Color(0xffe8eef6);

  static Color multicolumn_chart_color = const Color(0xffF87073);
}
