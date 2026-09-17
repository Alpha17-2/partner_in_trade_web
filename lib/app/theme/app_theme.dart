import 'package:flutter/material.dart';

import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    const colors = AppColors.dark;

    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: colors.accent,
      onPrimary: colors.background,
      secondary: colors.textSecondary,
      onSecondary: colors.textPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      error: colors.negative,
      onError: colors.textPrimary,
      outline: colors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.borderSubtle,
      extensions: const [colors],
      textTheme: AppTextStyles.textTheme(colors),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: colors.borderSubtle),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        titleTextStyle: AppTextStyles.textTheme(colors).titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.borderStrong),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: TextStyle(color: colors.textTertiary),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.navActive,
        selectedIconTheme: IconThemeData(color: colors.textPrimary),
        unselectedIconTheme: IconThemeData(color: colors.textSecondary),
        labelType: NavigationRailLabelType.all,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: IconThemeData(color: colors.textSecondary, size: 20),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
