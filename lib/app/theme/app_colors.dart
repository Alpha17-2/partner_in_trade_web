import 'package:flutter/material.dart';

/// Semantic color palette for Partner in Trade (dark theme).
class AppColorPalette {
  static const background = Color(0xFF0B0D10);
  static const surface = Color(0xFF12151A);
  static const surfaceElevated = Color(0xFF181C22);

  static const borderSubtle = Color(0xFF252A33);
  static const borderStrong = Color(0xFF353C48);

  static const textPrimary = Color(0xFFF4F5F7);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textTertiary = Color(0xFF6B7280);

  static const positive = Color(0xFF22C55E);
  static const negative = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static const chartGrid = Color(0xFF1F2430);
  static const chartAxis = Color(0xFF4B5563);

  static const accent = Color(0xFFE8EAED);
  static const sidebarHover = Color(0xFF1A1F27);
  static const navActive = Color(0xFF232933);
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.positive,
    required this.negative,
    required this.warning,
    required this.chartGrid,
    required this.chartAxis,
    required this.accent,
    required this.sidebarHover,
    required this.navActive,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color positive;
  final Color negative;
  final Color warning;
  final Color chartGrid;
  final Color chartAxis;
  final Color accent;
  final Color sidebarHover;
  final Color navActive;

  static const dark = AppColors(
    background: AppColorPalette.background,
    surface: AppColorPalette.surface,
    surfaceElevated: AppColorPalette.surfaceElevated,
    borderSubtle: AppColorPalette.borderSubtle,
    borderStrong: AppColorPalette.borderStrong,
    textPrimary: AppColorPalette.textPrimary,
    textSecondary: AppColorPalette.textSecondary,
    textTertiary: AppColorPalette.textTertiary,
    positive: AppColorPalette.positive,
    negative: AppColorPalette.negative,
    warning: AppColorPalette.warning,
    chartGrid: AppColorPalette.chartGrid,
    chartAxis: AppColorPalette.chartAxis,
    accent: AppColorPalette.accent,
    sidebarHover: AppColorPalette.sidebarHover,
    navActive: AppColorPalette.navActive,
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? borderSubtle,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? positive,
    Color? negative,
    Color? warning,
    Color? chartGrid,
    Color? chartAxis,
    Color? accent,
    Color? sidebarHover,
    Color? navActive,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      warning: warning ?? this.warning,
      chartGrid: chartGrid ?? this.chartGrid,
      chartAxis: chartAxis ?? this.chartAxis,
      accent: accent ?? this.accent,
      sidebarHover: sidebarHover ?? this.sidebarHover,
      navActive: navActive ?? this.navActive,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      chartGrid: Color.lerp(chartGrid, other.chartGrid, t)!,
      chartAxis: Color.lerp(chartAxis, other.chartAxis, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      sidebarHover: Color.lerp(sidebarHover, other.sidebarHover, t)!,
      navActive: Color.lerp(navActive, other.navActive, t)!,
    );
  }
}
