import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_ui_providers.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../services/delta/delta_config.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../providers/delta_connection_provider.dart';

class DeltaConnectionSection extends ConsumerStatefulWidget {
  const DeltaConnectionSection({super.key});

  @override
  ConsumerState<DeltaConnectionSection> createState() =>
      _DeltaConnectionSectionState();
}

class _DeltaConnectionSectionState extends ConsumerState<DeltaConnectionSection> {
  final _apiKeyController = TextEditingController();
  final _apiSecretController = TextEditingController();
  bool _obscureSecret = true;
  bool _testing = false;
  Timer? _autosaveDebounce;
  bool _fieldsHydrated = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController.addListener(_scheduleAutosave);
    _apiSecretController.addListener(_scheduleAutosave);
  }

  @override
  void dispose() {
    _autosaveDebounce?.cancel();
    _apiKeyController.removeListener(_scheduleAutosave);
    _apiSecretController.removeListener(_scheduleAutosave);
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    super.dispose();
  }

  void _hydrateFieldsFromStore() {
    if (_fieldsHydrated) return;
    final creds = ref.read(deltaCredentialsStoreProvider).read();
    if (creds != null) {
      _apiKeyController.text = creds.apiKey;
      _apiSecretController.text = creds.apiSecret;
      ref.read(deltaEnvironmentProvider.notifier).state = creds.environment;
    }
    _fieldsHydrated = true;
  }

  void _scheduleAutosave() {
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(const Duration(milliseconds: 400), _persistDraft);
  }

  void _persistDraft() {
    ref.read(deltaCredentialsStoreProvider).saveDraft(
          apiKey: _apiKeyController.text.trim(),
          apiSecret: _apiSecretController.text.trim(),
          environment: ref.read(deltaEnvironmentProvider),
        );
  }

  @override
  Widget build(BuildContext context) {
    _hydrateFieldsFromStore();
    final colors = context.appColors;
    final connection = ref.watch(deltaConnectionControllerProvider);
    final environment = ref.watch(deltaEnvironmentProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Delta Exchange',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Read-only API access (India). Keys need Read Data; wallet and orders '
          'tests also require Trading permission on the key.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        DropdownButtonFormField<DeltaEnvironment>(
          initialValue: environment,
          decoration: const InputDecoration(labelText: 'Environment'),
          items: DeltaEnvironment.values
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.label),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(deltaEnvironmentProvider.notifier).state = value;
              _persistDraft();
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _apiKeyController,
          decoration: const InputDecoration(labelText: 'API Key'),
          autocorrect: false,
          enableSuggestions: false,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _apiSecretController,
          decoration: InputDecoration(
            labelText: 'API Secret',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureSecret = !_obscureSecret),
              icon: Icon(
                _obscureSecret ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
            ),
          ),
          obscureText: _obscureSecret,
          autocorrect: false,
          enableSuggestions: false,
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text('Connection status', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: AppSpacing.md),
            _statusBadge(connection.status),
          ],
        ),
        if (connection.message != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            connection.message!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: connection.status == DeltaConnectionStatus.error
                      ? colors.negative
                      : colors.textSecondary,
                ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            PrimaryButton(
              label: 'Connect',
              onPressed: _testing
                  ? null
                  : () {
                      ref.read(deltaConnectionControllerProvider.notifier).connect(
                            apiKey: _apiKeyController.text,
                            apiSecret: _apiSecretController.text,
                            environment: environment,
                          );
                    },
            ),
            SecondaryButton(
              label: _testing ? 'Testing…' : 'Test Connection',
              onPressed: _testing ? null : _runTest,
            ),
            if (connection.status == DeltaConnectionStatus.connected)
              SecondaryButton(
                label: 'Disconnect',
                onPressed: () {
                  ref.read(deltaConnectionControllerProvider.notifier).disconnect();
                  _apiKeyController.clear();
                  _apiSecretController.clear();
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'API key and secret are autosaved in this browser (IndexedDB via Hive) '
          'and restored on reload. Anyone with access to this device or devtools '
          'can read them. Use Disconnect to remove saved keys. Do not host this '
          'app publicly with real keys.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.textTertiary,
              ),
        ),
      ],
    );
  }

  Future<void> _runTest() async {
    setState(() => _testing = true);
    await ref.read(deltaConnectionControllerProvider.notifier).testConnection(
          apiKey: _apiKeyController.text,
          apiSecret: _apiSecretController.text,
          environment: ref.read(deltaEnvironmentProvider),
        );
    setState(() => _testing = false);
  }

  Widget _statusBadge(DeltaConnectionStatus status) {
    switch (status) {
      case DeltaConnectionStatus.connected:
        return const StatusBadge(
          label: 'Connected',
          variant: StatusBadgeVariant.success,
        );
      case DeltaConnectionStatus.error:
        return const StatusBadge(
          label: 'Error',
          variant: StatusBadgeVariant.danger,
        );
      case DeltaConnectionStatus.notConnected:
        return const StatusBadge(
          label: 'Not Connected',
          variant: StatusBadgeVariant.neutral,
        );
    }
  }
}
