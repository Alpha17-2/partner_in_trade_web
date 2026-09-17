import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: AppColorPalette.background.withValues(alpha: 0.4),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
