import 'package:flutter/material.dart';

import '../models/reconstruction_job.dart';

class ModelPreviewPage extends StatelessWidget {
  const ModelPreviewPage({super.key, required this.job});
  final ReconstructionJob job;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(job.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _exportModel(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.view_in_ar, size: 120, color: Color(0xFF0B6E4F)),
            const SizedBox(height: 24),
            Text('3D模型预览', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text('${job.photos.length} 张照片 · ${(job.progress * 100).round()}% 完成'),
            const SizedBox(height: 32),
            if (job.previewUrl != null)
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('加载预览'),
              ),
          ],
        ),
      ),
    );
  }

  void _exportModel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出模型'),
        content: const Text('选择导出格式：SPLAT, PLY, GLB'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('模型导出功能开发中')),
              );
            },
            child: const Text('导出'),
          ),
        ],
      ),
    );
  }
}
