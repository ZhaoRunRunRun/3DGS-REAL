import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/reconstruction_job.dart';

class JobStatusCard extends StatelessWidget {
  const JobStatusCard({
    super.key,
    required this.job,
    this.onPreview,
  });

  final ReconstructionJob job;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressLabel = '${(job.progress * 100).toStringAsFixed(0)}%';
    final qualifiedRate = job.photos.isEmpty
        ? 0
        : (job.photos.where((photo) => photo.isQualified).length / job.photos.length * 100)
            .round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(job.name, style: theme.textTheme.titleLarge),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(job.mode.title),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(job.message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: job.progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(999),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('进度 $progressLabel', style: theme.textTheme.labelLarge),
                const Spacer(),
                Text(DateFormat('MM-dd HH:mm').format(job.createdAt)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _FactChip(label: '照片', value: '${job.photos.length} 张'),
                _FactChip(label: '合格率', value: '$qualifiedRate%'),
                _FactChip(label: '状态', value: job.status.name),
              ],
            ),
            if (job.status == ReconstructionJobStatus.done && onPreview != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onPreview,
                icon: const Icon(Icons.visibility),
                label: const Text('预览模型'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEE8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text('$label: $value'),
    );
  }
}
