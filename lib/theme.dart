import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color background = Color(0xFFECF4F7);

  // Accent Colors
  static const Color yellow = Color(0xFFFFB74D);
  static const Color yellowContrast = Color(0xFFFFF3E0);
  static const Color green = Color(0xFF3AEF30);
  static const Color hotPink = Color(0xFFEF30A2);
  static const Color blue = Color(0xFF0BC7DC);
  static const Color red = Color(0xFFF30541);
  static const Color purple = Color(0xFFDA05F3);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Text Colors
  static const Color primaryText = Color(0xFF000000);
  static const Color secondaryText = Color(0xFF666666);
  static const Color tertiaryText = Color(0xFF999999);

  // Main Colors
  static const Color primary = yellow;
  static const Color secondary = blue;
}

const fontFamily = "Comfortaa-Bold";

CupertinoThemeData getTheme() {
  return CupertinoThemeData(
    brightness: Brightness.light, // Explicitly lock to light mode
    primaryColor: AppColors.primary,
    primaryContrastingColor: AppColors.black,
    scaffoldBackgroundColor: AppColors.background,
    barBackgroundColor: AppColors.background,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.primaryText,
      textStyle: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.primaryText,
      ),
      actionTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.primary,
      ),
      tabLabelTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.secondaryText,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.primaryText,
        fontWeight: FontWeight.bold,
      ),
      navActionTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.primary,
      ),
      pickerTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.primaryText,
      ),
      dateTimePickerTextStyle: TextStyle(
        fontFamily: fontFamily,
        color: AppColors.primaryText,
      ),
    ),
  );
}
