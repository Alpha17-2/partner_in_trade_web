import 'package:flutter/material.dart';

import '../../app/theme/app_text_styles.dart';
import '../../core/extensions/context_extensions.dart';

enum PnlFormat { currency, percent, plain }

class PnlText extends StatelessWidget {
  const PnlText({
    super.key,
    required this.value,
    this.format = PnlFormat.currency,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.showSign = true,
    this.neutralIfZero = true,
  });

  final double value;
  final PnlFormat format;
  final double fontSize;
  final FontWeight fontWeight;
  final bool showSign;
  final bool neutralIfZero;

  String _formatValue() {
    final sign = value > 0 ? '+' : value < 0 ? '-' : '';
    final abs = value.abs();

    switch (format) {
      case PnlFormat.currency:
        final formatted = abs.toStringAsFixed(2);
        return showSign && value != 0 ? '$sign\$$formatted' : '\$${value.toStringAsFixed(2)}';
      case PnlFormat.percent:
        final formatted = abs.toStringAsFixed(1);
        return showSign && value != 0 ? '$sign$formatted%' : '${value.toStringAsFixed(1)}%';
      case PnlFormat.plain:
        final formatted = abs.toStringAsFixed(2);
        return showSign && value != 0 ? '$sign$formatted' : value.toStringAsFixed(2);
    }
  }

  Color _color(BuildContext context) {
    final colors = context.appColors;
    if (neutralIfZero && value == 0) return colors.textPrimary;
    if (value > 0) return colors.positive;
    if (value < 0) return colors.negative;
    return colors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatValue(),
      style: AppTextStyles.mono(
        context.appColors,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: _color(context),
      ),
    );
  }
}
