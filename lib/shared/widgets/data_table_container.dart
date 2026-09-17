import 'package:flutter/material.dart';

import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';

class DataTableColumn {
  const DataTableColumn({
    required this.label,
    this.flex = 1,
    this.align = TextAlign.start,
  });

  final String label;
  final int flex;
  final TextAlign align;
}

class DataTableRow {
  const DataTableRow({required this.cells});

  final List<Widget> cells;
}

class DataTableContainer extends StatelessWidget {
  const DataTableContainer({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<DataTableColumn> columns;
  final List<DataTableRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Column(
          children: [
            Container(
              color: colors.surfaceElevated,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  for (var i = 0; i < columns.length; i++)
                    Expanded(
                      flex: columns[i].flex,
                      child: Text(
                        columns[i].label,
                        textAlign: columns[i].align,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                ],
              ),
            ),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'No data',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              for (var r = 0; r < rows.length; r++)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var c = 0; c < columns.length; c++)
                        Expanded(
                          flex: columns[c].flex,
                          child: Align(
                            alignment: columns[c].align == TextAlign.end
                                ? Alignment.centerRight
                                : columns[c].align == TextAlign.center
                                    ? Alignment.center
                                    : Alignment.centerLeft,
                            child: rows[r].cells[c],
                          ),
                        ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
