import 'dart:developer';

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      cardTheme: const CardTheme(
        margin: EdgeInsets.only(left: 10, right: 10, top: 10),

      ),
    );
  }

  static double getResponsiveWidthContent(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width < 500) {
      return width * 1; // xs
    }
    else if (width > 500 && width < 600) {
      return width * 0.85; // sm
    } else if (width > 600 && width < 950) {
      return width * 0.65; // sm
    }
    else if (width < 1050) {
      return width * 0.65; // md
    } else if (width < 1200) {
      return width * 0.50; // md
    } else if (width < 1500) {
      return width * 0.40; // lg
    } else {
      return width * 0.30; // xl
    }
  }

  static double getResponsiveWidthForms(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return width * 0.85; // xs
    } else if (width < 900) {
      return width * 0.55; // sm
    } else if (width < 1200) {
      return width * 0.45; // md
    } else if (width < 1500) {
      return width * 0.35; // lg
    } else {
      return width * 0.25; // xl
    }
  }

  static FloatingActionButtonLocation fABPosition(BuildContext context){
    if(MediaQuery.of(context).size.width > 500){
      return FloatingActionButtonLocation.centerFloat;
    }else{
      return FloatingActionButtonLocation.endFloat;
    }
  }

  static double dropdownMenuWidthSp(BuildContext context){
    double width = MediaQuery.of(context).size.width;

    if(MediaQuery.of(context).size.width < 600){
      return MediaQuery.of(context).size.width * 0.65;
    } else if (width < 1050) {
      return getResponsiveWidthContent(context) - MediaQuery.of(context).size.width * 0.20;
    }
    else{
      return getResponsiveWidthContent(context) - MediaQuery.of(context).size.width * 0.10;
    }
  }

  // static double dropdownMenuWidth(BuildContext context){
  //   return getResponsiveWidthContent(context) - MediaQuery.of(context).size.width * 0.10;
  // }
}
