import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/navigation/app_routes.dart';
import '../../app/providers/app_ui_providers.dart';
import '../../core/extensions/context_extensions.dart';
import 'app_header.dart';
import 'app_sidebar.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _compactBreakpoint = 1024;

  String _currentPath(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  String? _headerTitle(String path) {
    final route = AppRoutes.all.where((r) => r.path == path).firstOrNull;
    return route?.label;
  }

  void _onRefresh() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Data refreshed'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < _compactBreakpoint;
    final path = _currentPath(context);
    final colors = context.appColors;
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final title = _headerTitle(path);

    if (compact) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: colors.background,
        drawer: Drawer(
          width: AppSidebar.expandedWidth,
          child: AppSidebar(
            collapsed: false,
            currentPath: path,
            showCollapseToggle: false,
          ),
        ),
        body: Column(
          children: [
            AppHeader(
              title: title,
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              onRefresh: _onRefresh,
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: Row(
        children: [
          AppSidebar(
            collapsed: collapsed,
            currentPath: path,
          ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  title: title,
                  onRefresh: _onRefresh,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
