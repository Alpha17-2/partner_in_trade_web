import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String fontFamily = 'Inter';
  static const String monoFamily = 'JetBrains Mono';

  static TextTheme textTheme(AppColors colors) {
    return TextTheme(
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colors.textTertiary,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colors.textTertiary,
        letterSpacing: 0.3,
      ),
    );
  }

  static TextStyle mono(
    AppColors colors, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: monoFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? colors.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle metricValue(AppColors colors) =>
      mono(colors, fontSize: 22, fontWeight: FontWeight.w600);

  static TextStyle sectionTitle(AppColors colors) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      );

  static TextStyle navLabel(AppColors colors, {bool active = false}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        fontWeight: active ? FontWeight.w500 : FontWeight.w400,
        color: active ? colors.textPrimary : colors.textSecondary,
      );
}
