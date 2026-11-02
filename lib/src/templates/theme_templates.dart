/// One shared responsive Material 3 theme, split by responsibility.
Map<String, String> themeTemplates() => {
  'lib/core/theme/app_colors.dart': '''
// Semantic colors used by the light and dark Material themes.
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Light theme.
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color onPrimaryLight = Colors.white;
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color errorLight = Color(0xFFDC2626);
  static const Color onErrorLight = Colors.white;

  // Dark theme.
  static const Color primaryDark = Color(0xFF3B82F6);
  static const Color onPrimaryDark = Colors.white;
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);
  static const Color errorDark = Color(0xFFEF4444);
  static const Color onErrorDark = Colors.black;
}
''',
  'lib/core/theme/app_text_theme.dart': '''
// Builds responsive text styles after Sizer initializes the viewport metrics.
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

abstract final class AppTextTheme {
  static TextTheme get textTheme {
    // Scale the whole type ramp proportionally, using a 16.sp reference.
    // Bound the base size on large screens; Flutter still applies the user's
    // accessibility TextScaler afterward without overriding MediaQuery.
    final scale = (16.sp / 16).clamp(1.0, 1.25).toDouble();
    return TextTheme(
      headlineLarge: TextStyle(fontSize: 32 * scale, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 24 * scale, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.normal),
      labelLarge: TextStyle(fontSize: 14 * scale, fontWeight: FontWeight.bold),
    );
  }
}
''',
  'lib/core/theme/app_theme.dart': '''
// Composes responsive colors, typography and component defaults inside Sizer.
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryLight).copyWith(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      error: AppColors.errorLight,
      onError: AppColors.onErrorLight,
    ),
    scaffoldBackground: AppColors.backgroundLight,
  );

  static ThemeData get dark => _buildTheme(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark, brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      error: AppColors.errorDark,
      onError: AppColors.onErrorDark,
    ),
    scaffoldBackground: AppColors.backgroundDark,
  );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
  }) {
    final textTheme = AppTextTheme.textTheme.apply(
      bodyColor: colorScheme.onSurface, displayColor: colorScheme.onSurface,
    );
    // Keep spacing responsive and bounded, with at least 48 logical pixels for
    // button targets. These getters run inside Sizer.builder on viewport changes.
    final radius = BorderRadius.circular(3.w.clamp(12.0, 20.0).toDouble());
    final cardRadius = BorderRadius.circular(4.w.clamp(16.0, 24.0).toDouble());
    final buttonHeight = 6.h.clamp(48.0, 56.0).toDouble();
    final horizontalPadding = 4.w.clamp(16.0, 24.0).toDouble();
    final verticalPadding = 1.75.h.clamp(14.0, 20.0).toDouble();
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: scaffoldBackground,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface, fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: Size(64, buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius, borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
          side: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.08)),
        ),
      ),
    );
  }
}
''',
};
