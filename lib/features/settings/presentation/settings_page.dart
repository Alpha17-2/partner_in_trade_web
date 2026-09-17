import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/page_container.dart';
import '../../../shared/widgets/section_header.dart';
import '../../sync/presentation/sync_panel.dart';
import 'widgets/delta_connection_section.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'Settings',
            subtitle: 'Application and exchange connection',
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: const DeltaConnectionSection(),
          ),
          const SizedBox(height: AppSpacing.xl),
          const AppCard(
            child: SyncPanel(),
          ),
        ],
      ),
    );
  }
}
