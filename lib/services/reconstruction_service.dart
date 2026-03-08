import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

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
    if (mode == ReconstructionMode.remote) {
      return _createRemoteJob(photos, settings);
    }
    return _createLocalJob(photos, settings);
  }

  Future<ReconstructionJob> _createRemoteJob(
    List<CapturePhoto> photos,
    ReconstructionSettings settings,
  ) async {
    try {
      final dio = Dio();
      final formData = FormData();

      for (final photo in photos) {
        if (await File(photo.path).exists()) {
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(photo.path, filename: photo.name),
          ));
        }
      }

      formData.fields.addAll([
        MapEntry('iterations', settings.iterations.toString()),
        MapEntry('use_colmap', settings.enableColmap.toString()),
      ]);

      final response = await dio.post(settings.serverEndpoint, data: formData);
      final jobId = response.data['job_id'] as String;

      return ReconstructionJob(
        id: jobId,
        name: 'Remote ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        mode: ReconstructionMode.remote,
        status: ReconstructionJobStatus.queued,
        photos: photos,
        progress: 0.05,
        createdAt: DateTime.now(),
        message: '远端任务已提交，等待服务器处理',
      );
    } catch (_) {
      return ReconstructionJob(
        id: 'remote_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Remote ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        mode: ReconstructionMode.remote,
        status: ReconstructionJobStatus.queued,
        photos: photos,
        progress: 0.08,
        createdAt: DateTime.now(),
        message: '远端服务暂不可用，使用模拟模式',
      );
    }
  }

  Future<ReconstructionJob> _createLocalJob(
    List<CapturePhoto> photos,
    ReconstructionSettings settings,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return ReconstructionJob(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Local ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      mode: ReconstructionMode.local,
      status: ReconstructionJobStatus.queued,
      photos: photos,
      progress: 0.08,
      createdAt: DateTime.now(),
      message: '本地管线已启动，准备执行质检与 COLMAP',
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
        message: '正在进行照片质量检查与去重',
      ),
      job.copyWith(
        status: ReconstructionJobStatus.processing,
        progress: 0.36,
        message: '正在执行 COLMAP 位姿恢复与稀疏重建',
      ),
      job.copyWith(
        status: ReconstructionJobStatus.processing,
        progress: 0.62,
        message: '正在训练 3D Gaussian Splatting 模型',
      ),
      job.copyWith(
        status: ReconstructionJobStatus.processing,
        progress: 0.86,
        message: '正在导出 splat / ply 产物与预览资源',
      ),
      job.copyWith(
        status: ReconstructionJobStatus.done,
        progress: 1,
        message: '建模完成，可导出结果或继续预览',
        previewUrl: 'preview://local-splat-viewer',
      ),
    ];

    for (final milestone in milestones) {
      await Future<void>.delayed(step);
      yield milestone;
    }
  }
}
