import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'page_container.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: EmptyState(
          title: title,
          message: 'Coming soon',
          icon: Icons.construction_outlined,
        ),
      ),
    );
  }
}
