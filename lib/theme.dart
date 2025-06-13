import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFFECF4F7);

  // Primary Colors
  static const Color primaryYellow = Color(0xFFFFB74D);
  static const Color yellowContrast = Color(0xFFFFF3E0);

  // Accent Colors
  static const Color brightGreen = Color(0xFF3AEF30);
  static const Color hotPink = Color(0xFFEF30A2);
  static const Color blue = Color(0xFF0BC7DC);
  static const Color red = Color(0xFFF30541);
  static const Color purple = Color(0xFFDA05F3);
  static const Color black = Color(0xFF000000);
}

const TITLE_FONT = "Comfortaa-Bold";
const TEXT_FONT = "Comfortaa-Light";

CupertinoThemeData getTheme(BuildContext context) {
  return CupertinoThemeData(
    primaryColor: AppColors.primaryYellow,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.background,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(fontFamily: TEXT_FONT),
    ),
  );
}
