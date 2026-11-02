import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const ink = Color(0xFF163F35);
  static const accent = Color(0xFFF0B68B);
  static const background = Color(0xFFF7F7F2);
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ink,
      surface: background,
    ).copyWith(primary: ink, secondary: const Color(0xFFB5633E)),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: ink),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: ink.withValues(alpha: .1),
      height: 76,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: Color(0xFF52625D),
      ),
    ),
  );
}
