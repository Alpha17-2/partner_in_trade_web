import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

extension BuildContextTheme on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.dark;

  TextStyle monoText({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return AppTextStyles.mono(
      appColors,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
