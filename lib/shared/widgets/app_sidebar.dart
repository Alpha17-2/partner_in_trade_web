import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/navigation/app_routes.dart';
import '../../app/providers/app_ui_providers.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/context_extensions.dart';
import 'delta_connection_chip.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    super.key,
    required this.collapsed,
    required this.currentPath,
    this.showCollapseToggle = true,
  });

  final bool collapsed;
  final String currentPath;
  final bool showCollapseToggle;

  static const expandedWidth = 240.0;
  static const collapsedWidth = 72.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: collapsed ? collapsedWidth : expandedWidth,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(color: colors.borderSubtle),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              collapsed ? AppSpacing.md : AppSpacing.xl,
              AppSpacing.xl,
              collapsed ? AppSpacing.md : AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: collapsed
                ? Center(
                    child: Tooltip(
                      message: 'Trade Analyzer',
                      child: Icon(
                        Icons.candlestick_chart,
                        color: colors.accent,
                        size: 28,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.candlestick_chart,
                        color: colors.accent,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Trade Analyzer',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? AppSpacing.sm : AppSpacing.md,
              ),
              children: [
                for (final route in AppRoutes.primary)
                  _NavItem(
                    route: route,
                    selected: AppRoutes.matches(currentPath, route.path),
                    collapsed: collapsed,
                    onTap: () => context.go(route.path),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                    horizontal: collapsed ? AppSpacing.xs : AppSpacing.sm,
                  ),
                  child: Divider(height: 1, color: colors.borderSubtle),
                ),
                _NavItem(
                  route: AppRoutes.settingsRoute,
                  selected: AppRoutes.matches(
                    currentPath,
                    AppRoutes.settingsRoute.path,
                  ),
                  collapsed: collapsed,
                  onTap: () => context.go(AppRoutes.settingsRoute.path),
                ),
              ],
            ),
          ),
          if (showCollapseToggle)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? AppSpacing.sm : AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Align(
                alignment:
                    collapsed ? Alignment.center : Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    ref.read(sidebarCollapsedProvider.notifier).state =
                        !collapsed;
                  },
                  icon: Icon(
                    collapsed
                        ? Icons.chevron_right
                        : Icons.chevron_left,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                  tooltip: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              collapsed ? AppSpacing.sm : AppSpacing.lg,
              AppSpacing.sm,
              collapsed ? AppSpacing.sm : AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: collapsed
                ? Tooltip(
                    message: 'Delta Exchange — Not connected',
                    child: Center(
                      child: Icon(
                        Icons.link_off_outlined,
                        size: 20,
                        color: colors.textTertiary,
                      ),
                    ),
                  )
                : const DeltaConnectionChip(
                    display: DeltaConnectionDisplay.verbose,
                  ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.route,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  final AppRoute route;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final item = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected ? colors.navActive : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            hoverColor: colors.sidebarHover,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? AppSpacing.sm : AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    route.icon,
                    size: 20,
                    color:
                        selected ? colors.textPrimary : colors.textSecondary,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        route.label,
                        style: AppTextStyles.navLabel(colors, active: selected),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(message: route.label, child: item);
    }
    return item;
  }
}
