import 'dart:async';

import '../models/capture_photo.dart';
import '../models/reconstruction_job.dart';
import '../models/reconstruction_mode.dart';
import '../models/reconstruction_settings.dart';

class ReconstructionService {
  const ReconstructionService();

  Future<ReconstructionJob> createJob({
    required ReconstructionMode mode,
    required List<CapturePhoto> photos,
    required ReconstructionSettings settings,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return ReconstructionJob(
      id: '${mode.name}_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Object scan ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      mode: mode,
      status: ReconstructionJobStatus.queued,
      photos: photos,
      progress: 0.08,
      createdAt: DateTime.now(),
      message: mode == ReconstructionMode.local
          ? '本地管线已启动，准备执行质检与 COLMAP。'
          : '远端任务已入队，准备上传图像与训练参数。',
    );
  }

  Stream<ReconstructionJob> watchJob(
    ReconstructionJob job, {
    Duration step = const Duration(milliseconds: 800),
  }) async* {
    final milestones = <ReconstructionJob>[
      job.copyWith(
        status: ReconstructionJobStatus.processing,
        progress: 0.18,
        message: '正在进行照片质量检查与去重。',
      ),
      job.copyWith(
        status: ReconstructionJobStatus.processing,
        progress: 0.36,
        message: '正在执行 COLMAP 位姿恢复与稀疏重建。',
      ),
      job.copyWith(
        status: ReconstructionJobStatus.processing,
        progress: 0.62,
        message: '正在训练 3D Gaussian Splatting 模型。',
      ),
      job.copyWith(
        status: ReconstructionJobStatus.processing,
        progress: 0.86,
        message: '正在导出 splat / ply 产物与预览资源。',
      ),
      job.copyWith(
        status: ReconstructionJobStatus.done,
        progress: 1,
        message: '建模完成，可导出结果或继续预览。',
        previewUrl: 'preview://local-splat-viewer',
      ),
    ];

    for (final milestone in milestones) {
      await Future<void>.delayed(step);
      yield milestone;
    }
  }
}
