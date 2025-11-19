import 'package:flutter/material.dart';

class AppTheme {
  static const Color scaffold = Color(0xFF0b0f1a);
  static const Color surface = Color(0xFF2B2B2B);
  static const Color black = Color(0xFF0b0f1a);
  static const Color gold = Color(0xFFD9BE77);
  static const Color calendarBg = Color(0xFFD4B868);
  static const Color textOnDark = Colors.white;

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: scaffold,
      primaryColor: gold,
      textTheme: Typography.whiteCupertino.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      useMaterial3: true,
    );
  }
}
