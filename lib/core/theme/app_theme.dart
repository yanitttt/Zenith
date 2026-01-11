import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color scaffold = Color(0xFF0b0f1a); // Bleu nuit profond
  static const Color surface = Color(
    0xFF0F0F1E,
  ); // Bleu surface légèrement plus clair
  static const Color gold = Color(0xFFD9BE77); // Doré principal
  static const Color goldDark = Color(
    0xFFC8B06A,
  ); // Doré plus foncé (pour dégradés)
  static const Color goldLight = Color(
    0xFFEAD9A5,
  ); // Doré plus clair (pour dégradés)
  static const Color calendarBg = Color(0xFFD4B868);
  static const Color textOnDark = Colors.white;

  // Couleurs sémantiques
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF4ECDC4);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: scaffold,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(height: 1.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: scaffold,
      primaryColor: gold,
      colorScheme: const ColorScheme.dark(
        primary: gold,
        surface: surface,
        onSurface: textOnDark,
      ),
      textTheme: Typography.whiteCupertino.apply(
        bodyColor: textOnDark,
        displayColor: textOnDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: scaffold,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}
