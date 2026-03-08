import 'dart:async';

import 'package:flutter/material.dart';

import '../models/capture_photo.dart';
import '../models/reconstruction_job.dart';
import '../models/reconstruction_mode.dart';
import '../models/reconstruction_settings.dart';
import '../services/capture_service.dart';
import '../services/photo_library_service.dart';
import '../services/reconstruction_service.dart';
import '../widgets/feature_card.dart';
import '../widgets/job_status_card.dart';
import '../widgets/photo_orbit_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _captureService = const CaptureService();
  final _photoLibraryService = const PhotoLibraryService();
  final _reconstructionService = const ReconstructionService();

  ReconstructionMode _selectedMode = ReconstructionMode.remote;
  ReconstructionSettings _settings = ReconstructionSettings.defaults;
  List<CapturePhoto> _photos = const [];
  List<ReconstructionJob> _jobs = const [];
  ReconstructionJob? _activeJob;
  StreamSubscription<ReconstructionJob>? _jobSubscription;
  bool _busy = false;
  String _status = '等待开始';

  @override
  void dispose() {
    _jobSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startGuidedCapture() async {
    setState(() {
      _busy = true;
      _status = '正在准备相机与环绕拍摄引导';
    });

    try {
      final preparation = await _captureService.prepareCameraGuide();
      final photos = await _captureService.generateDemoCapture(count: 48);

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _photos = photos;
        _status = preparation.usingFallback
            ? '${preparation.message} 已生成 ${photos.length} 张演示环绕照片。'
            : '${preparation.message} 当前先用 ${photos.length} 张演示照片串起后续建模流程。';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _status = '启动拍摄流程失败，请稍后重试。';
      });
    }
  }

  Future<void> _importGalleryPhotos() async {
    setState(() {
      _busy = true;
      _status = '正在从相册导入环绕照片';
    });

    try {
      final result = await _photoLibraryService.importOrbitPhotos();

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        if (result.photos.isNotEmpty) {
          _photos = result.photos;
        }
        _status = result.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _status = '导入照片失败，请检查文件权限后重试。';
      });
    }
  }

  Future<void> _startReconstruction() async {
    if (_photos.isEmpty) {
      setState(() {
        _status = '请先拍摄或导入一组环绕照片';
      });
      return;
    }

    final selectedPhotos = _settings.enableQualityFilter
        ? _photos.where((photo) => photo.isQualified).toList()
        : _photos;

    if (selectedPhotos.isEmpty) {
      setState(() {
        _status = '质检过滤后没有可用照片，请关闭过滤或重新补拍。';
      });
      return;
    }

    setState(() {
      _busy = true;
      _status = '正在提交 3DGS 重建任务';
    });

    try {
      final draftJob = await _reconstructionService.createJob(
        mode: _selectedMode,
        photos: selectedPhotos,
        settings: _settings,
      );

      await _jobSubscription?.cancel();

      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _activeJob = draftJob;
        _jobs = [draftJob, ..._jobs.where((item) => item.id != draftJob.id)];
        _status = draftJob.message;
      });

      _jobSubscription = _reconstructionService.watchJob(draftJob).listen((job) {
        if (!mounted) {
          return;
        }

        setState(() {
          _activeJob = job;
          _jobs = [
            job,
            ..._jobs.where((item) => item.id != job.id),
          ];
          _status = job.message;
        });
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _busy = false;
        _status = '提交重建任务失败，请检查配置后重试。';
      });
    }
  }

  void _toggleMode(ReconstructionMode mode) {
    setState(() {
      _selectedMode = mode;
      _status = '已切换为 ${mode.title}';
    });
  }

  void _updateIterations(double value) {
    setState(() {
      _settings = _settings.copyWith(iterations: value.round());
    });
  }

  void _updateQualityFilter(bool value) {
    setState(() {
      _settings = _settings.copyWith(enableQualityFilter: value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qualifiedCount = _photos.where((photo) => photo.isQualified).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroSection(
                    status: _status,
                    busy: _busy,
                    onCapture: _startGuidedCapture,
                    onReconstruct: _startReconstruction,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 920;
                      return Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('采集与建模控制台', style: theme.textTheme.headlineSmall),
                                        const SizedBox(height: 8),
                                        Text(
                                          '支持拍摄引导、相册导入、质量筛选、本地/远端重建切换与模型产物导出。',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 24),
                                        SegmentedButton<ReconstructionMode>(
                                          segments: ReconstructionMode.values
                                              .map(
                                                (mode) => ButtonSegment<ReconstructionMode>(
                                                  value: mode,
                                                  label: Text(mode.title),
                                                  icon: Icon(
                                                    mode == ReconstructionMode.local
                                                        ? Icons.memory_outlined
                                                        : Icons.cloud_upload_outlined,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          selected: {_selectedMode},
                                          onSelectionChanged: _busy
                                              ? null
                                              : (selection) => _toggleMode(selection.first),
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEAF4EA),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _selectedMode.description,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Text('训练迭代：${_settings.iterations}', style: theme.textTheme.titleMedium),
                                        Slider(
                                          min: 10000,
                                          max: 50000,
                                          divisions: 8,
                                          value: _settings.iterations.toDouble(),
                                          label: '${_settings.iterations}',
                                          onChanged: _busy ? null : _updateIterations,
                                        ),
                                        SwitchListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: const Text('启用照片质量过滤'),
                                          subtitle: const Text('自动过滤模糊/覆盖不足的图片，降低重建失败率'),
                                          value: _settings.enableQualityFilter,
                                          onChanged: _busy ? null : _updateQualityFilter,
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: [
                                            FilledButton.icon(
                                              onPressed: _busy ? null : _startGuidedCapture,
                                              icon: const Icon(Icons.videocam_outlined),
                                              label: const Text('相机引导拍摄'),
                                            ),
                                            FilledButton.tonalIcon(
                                              onPressed: _busy ? null : _importGalleryPhotos,
                                              icon: const Icon(Icons.photo_library_outlined),
                                              label: const Text('导入相册照片'),
                                            ),
                                            FilledButton.tonalIcon(
                                              onPressed: _busy ? null : _startReconstruction,
                                              icon: const Icon(Icons.rocket_launch_outlined),
                                              label: const Text('启动 3DGS 建模'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text('照片轨道与质检', style: theme.textTheme.headlineSmall),
                                            ),
                                            Text('合格 $qualifiedCount / ${_photos.length}'),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        if (_photos.isEmpty)
                                          const Text('还没有照片，先拍一圈或者从相册导入。')
                                        else
                                          Wrap(
                                            spacing: 24,
                                            runSpacing: 24,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              PhotoOrbitChart(photos: _photos),
                                              SizedBox(
                                                width: 520,
                                                child: Wrap(
                                                  spacing: 10,
                                                  runSpacing: 10,
                                                  children: _photos.take(12).map((photo) {
                                                    return Container(
                                                      width: 150,
                                                      padding: const EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: photo.isQualified
                                                            ? const Color(0xFFEAF4EA)
                                                            : const Color(0xFFFFECE9),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(photo.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                                          const SizedBox(height: 6),
                                                          Text('角度 ${photo.angle.toStringAsFixed(0)}°'),
                                                          Text('评分 ${(photo.qualityScore * 100).round()}'),
                                                          Text(
                                                            photo.source == 'gallery' ? '来源 相册' : '来源 相机',
                                                            style: theme.textTheme.bodySmall,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (_activeJob != null) JobStatusCard(job: _activeJob!),
                                const SizedBox(height: 20),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('任务列表', style: theme.textTheme.headlineSmall),
                                        const SizedBox(height: 16),
                                        if (_jobs.isEmpty)
                                          const Text('暂无任务，启动一次建模后会出现在这里。')
                                        else
                                          ..._jobs.map(
                                            (job) => ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: CircleAvatar(
                                                backgroundColor: const Color(0xFFEAF4EA),
                                                child: Text('${(job.progress * 100).round()}'),
                                              ),
                                              title: Text(job.name),
                                              subtitle: Text(job.message),
                                              trailing: Text(job.status.name),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: isWide ? 20 : 0, height: isWide ? 0 : 20),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                const FeatureCard(
                                  title: '环绕拍摄引导',
                                  description: '先完成权限与设备探测，下一步接入实时预览、角度覆盖层与姿态校验。',
                                  icon: Icons.threesixty,
                                ),
                                const SizedBox(height: 16),
                                const FeatureCard(
                                  title: '真实相册导入',
                                  description: '已接入文件选择器，可批量选择图像并映射为一圈环绕拍摄序列。',
                                  icon: Icons.perm_media_outlined,
                                ),
                                const SizedBox(height: 16),
                                const FeatureCard(
                                  title: '3DGS 管线预留',
                                  description: '可对接 COLMAP 位姿恢复、3D Gaussian Splatting 训练与模型导出。',
                                  icon: Icons.view_in_ar_outlined,
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('导出格式', style: theme.textTheme.titleLarge),
                                        const SizedBox(height: 12),
                                        _ExportRow(label: 'SPLAT', enabled: _settings.exportSplat),
                                        _ExportRow(label: 'PLY', enabled: _settings.exportPly),
                                        _ExportRow(label: 'GLB', enabled: _settings.exportGlb),
                                        const SizedBox(height: 16),
                                        Text('远端接口：', style: theme.textTheme.titleSmall),
                                        const SizedBox(height: 6),
                                        Text(_settings.serverEndpoint, style: theme.textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.status,
    required this.busy,
    required this.onCapture,
    required this.onReconstruct,
  });

  final String status;
  final bool busy;
  final Future<void> Function() onCapture;
  final Future<void> Function() onReconstruct;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF073B3A), Color(0xFF0B6E4F), Color(0xFF6BBF59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Wrap(
        runSpacing: 20,
        spacing: 20,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 640,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '3D Gaussian Splatting Workbench',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '3DGS REAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '引导用户围绕目标物体旋转拍摄，或直接导入环绕照片，在本地/云端完成 3D Gauss 建模、任务跟踪与结果导出。',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: busy ? null : onCapture,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('开始引导拍摄'),
                    ),
                    OutlinedButton.icon(
                      onPressed: busy ? null : onReconstruct,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                      ),
                      icon: const Icon(Icons.auto_awesome_motion_outlined),
                      label: const Text('启动 3DGS 重建'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 290,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '任务状态',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  status,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 18),
                LinearProgressIndicator(
                  value: busy ? null : 0.4,
                  borderRadius: BorderRadius.circular(99),
                  backgroundColor: Colors.white24,
                  color: const Color(0xFFF2C14E),
                ),
                const SizedBox(height: 12),
                const Text(
                  '推荐流程：采集 -> 质检 -> 位姿恢复 -> 3DGS 训练 -> 导出模型',
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportRow extends StatelessWidget {
  const _ExportRow({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_outline : Icons.remove_circle_outline,
            size: 18,
            color: enabled ? const Color(0xFF0B6E4F) : const Color(0xFF8D8D8D),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
