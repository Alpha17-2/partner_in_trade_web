import 'package:flutter/material.dart';

import '../../core/constants/app_radius.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      child: child,
    );

    final decoration = BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      border: Border.all(color: colors.borderSubtle),
      boxShadow: AppShadows.card,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Ink(
              decoration: decoration,
              child: content,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      child: content,
    );
  }
}
