import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../application/journal_image_processor.dart';
import '../../domain/daily_journal_image.dart';
import '../../providers/journal_providers.dart';

class JournalScreenshotGallery extends ConsumerWidget {
  const JournalScreenshotGallery({
    super.key,
    required this.dateKey,
  });

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesAsync = ref.watch(dailyJournalImagesProvider(dateKey));
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Screenshots',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => _add(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Screenshot'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        imagesAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('$e'),
          data: (metas) {
            if (metas.isEmpty) {
              return Text(
                'No screenshots yet',
                style: TextStyle(color: colors.textTertiary),
              );
            }
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: metas
                  .map(
                    (m) => _ThumbCard(
                      meta: m,
                      dateKey: dateKey,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
      withData: true,
      allowMultiple: true,
    );
    if (result == null) return;
    final repo = await ref.read(dailyJournalRepositoryProvider.future);
    final processor = JournalImageProcessor();
    for (final file in result.files) {
      final bytes = file.bytes;
      if (bytes == null) continue;
      try {
        final processed = processor.process(bytes, fileName: file.name);
        final id =
            '${dateKey}_${DateTime.now().microsecondsSinceEpoch}_${file.name.hashCode}';
        await repo.saveImage(
          meta: DailyJournalImageMeta(
            id: id,
            journalDate: dateKey,
            createdAt: DateTime.now(),
            fileName: file.name,
            mimeType: processed.mimeType,
            size: processed.size,
            width: processed.width,
            height: processed.height,
          ),
          bytes: processed.bytes,
          thumbnail: processed.thumbnail,
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not add ${file.name}: $e')),
          );
        }
      }
    }
    ref.read(dailyJournalRevisionProvider.notifier).state++;
  }
}

class _ThumbCard extends ConsumerWidget {
  const _ThumbCard({required this.meta, required this.dateKey});

  final DailyJournalImageMeta meta;
  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final thumb = ref.watch(journalThumbnailProvider(meta.id));
    final sizeLabel = meta.size < 1024 * 1024
        ? '${(meta.size / 1024).toStringAsFixed(0)} KB'
        : '${(meta.size / (1024 * 1024)).toStringAsFixed(1)} MB';

    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: colors.surfaceElevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () => _openLightbox(context, ref),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  height: 110,
                  width: 180,
                  child: thumb.when(
                    data: (bytes) {
                      if (bytes == null) {
                        return const Center(child: Icon(Icons.broken_image));
                      }
                      return Image.memory(bytes, fit: BoxFit.cover);
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, _) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meta.fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11),
          ),
          Text(
            sizeLabel,
            style: TextStyle(fontSize: 10, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }

  Future<void> _openLightbox(BuildContext context, WidgetRef ref) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _LightboxDialog(meta: meta, dateKey: dateKey),
    );
  }
}

class _LightboxDialog extends ConsumerStatefulWidget {
  const _LightboxDialog({required this.meta, required this.dateKey});

  final DailyJournalImageMeta meta;
  final String dateKey;

  @override
  ConsumerState<_LightboxDialog> createState() => _LightboxDialogState();
}

class _LightboxDialogState extends ConsumerState<_LightboxDialog> {
  late final TextEditingController _caption;
  late JournalScreenshotType _type;

  @override
  void initState() {
    super.initState();
    _caption = TextEditingController(text: widget.meta.caption ?? '');
    _type = widget.meta.type;
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bytesAsync = ref.watch(journalImageBytesProvider(widget.meta.id));
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 800),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.meta.fileName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: bytesAsync.when(
                  data: (bytes) {
                    if (bytes == null) return const Text('Image missing');
                    return InteractiveViewer(
                      child: Image.memory(bytes, fit: BoxFit.contain),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _caption,
                decoration: const InputDecoration(labelText: 'Caption'),
                onChanged: (_) => _saveMeta(),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<JournalScreenshotType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: JournalScreenshotType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _type = v);
                  _saveMeta();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveMeta() async {
    final repo = await ref.read(dailyJournalRepositoryProvider.future);
    await repo.updateImageMeta(
      widget.meta.copyWith(caption: _caption.text, type: _type),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete screenshot?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final repo = await ref.read(dailyJournalRepositoryProvider.future);
    await repo.deleteImage(widget.dateKey, widget.meta.id);
    ref.read(dailyJournalRevisionProvider.notifier).state++;
    if (context.mounted) Navigator.pop(context);
  }
}
