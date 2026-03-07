import 'package:flutter/material.dart';

import '../models/reconstruction_mode.dart';
import '../services/capture_service.dart';
import '../services/reconstruction_service.dart';
import '../widgets/feature_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _captureService = const CaptureService();
  final _reconstructionService = const ReconstructionService();

  ReconstructionMode _selectedMode = ReconstructionMode.remote;
  int _imageCount = 48;
  bool _busy = false;
  String _status = '等待开始';

  Future<void> _startGuidedCapture() async {
    setState(() {
      _busy = true;
      _status = '正在准备相机与环绕拍摄引导';
    });

    await _captureService.prepareCameraGuide();

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
      _status = '相机已就绪：建议按 24~72 张照片完成一圈拍摄';
    });
  }

  Future<void> _startReconstruction() async {
    setState(() {
      _busy = true;
      _status = '正在提交 3DGS 重建任务';
    });

    final jobId = await _reconstructionService.startJob(
      mode: _selectedMode,
      imageCount: _imageCount,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _busy = false;
      _status = '任务已创建：$jobId';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                          width: 620,
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
                                '引导用户围绕目标旋转拍摄，或直接导入环绕照片，在本地/云端完成 3D Gauss 建模与结果预览。',
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
                                    onPressed: _busy ? null : _startGuidedCapture,
                                    icon: const Icon(Icons.camera_alt_outlined),
                                    label: const Text('开始引导拍摄'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _busy ? null : _startReconstruction,
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
                          width: 280,
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
                                _status,
                                style: const TextStyle(color: Colors.white70, height: 1.5),
                              ),
                              const SizedBox(height: 18),
                              LinearProgressIndicator(
                                value: _busy ? null : 0.32,
                                borderRadius: BorderRadius.circular(99),
                                backgroundColor: Colors.white24,
                                color: const Color(0xFFF2C14E),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '建议流程：采集 -> 质检 -> 稀疏重建 -> 3DGS 训练 -> 导出模型',
                                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 860;
                      return Flex(
                        direction: isWide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('采集与建模控制台', style: theme.textTheme.headlineSmall),
                                    const SizedBox(height: 8),
                                    Text(
                                      '支持实时拍摄引导、相册批量导入、重建模式切换，以及后续接入 COLMAP / gsplat / diff-gaussian-rasterization 管线。',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 24),
                                    Text('图片数量：$_imageCount 张', style: theme.textTheme.titleMedium),
                                    Slider(
                                      min: 24,
                                      max: 120,
                                      divisions: 16,
                                      value: _imageCount.toDouble(),
                                      label: '$_imageCount',
                                      onChanged: _busy
                                          ? null
                                          : (value) {
                                              setState(() {
                                                _imageCount = value.round();
                                              });
                                            },
                                    ),
                                    const SizedBox(height: 8),
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
                                          : (selection) {
                                              setState(() {
                                                _selectedMode = selection.first;
                                              });
                                            },
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
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        FilledButton.icon(
                                          onPressed: _busy ? null : _startGuidedCapture,
                                          icon: const Icon(Icons.videocam_outlined),
                                          label: const Text('相机引导'),
                                        ),
                                        FilledButton.tonalIcon(
                                          onPressed: _busy ? null : () {},
                                          icon: const Icon(Icons.photo_library_outlined),
                                          label: const Text('导入相册照片'),
                                        ),
                                        FilledButton.tonalIcon(
                                          onPressed: _busy ? null : _startReconstruction,
                                          icon: const Icon(Icons.rocket_launch_outlined),
                                          label: const Text('提交建模任务'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isWide ? 20 : 0, height: isWide ? 0 : 20),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: const [
                                FeatureCard(
                                  title: '环绕拍摄引导',
                                  description: '实时提示拍摄角度、覆盖率与运动速度，降低重建失败率。',
                                  icon: Icons.threesixty,
                                ),
                                SizedBox(height: 16),
                                FeatureCard(
                                  title: '本地 / 云端双模式',
                                  description: '桌面端偏本地训练，移动端偏远端任务分发，兼顾性能与体验。',
                                  icon: Icons.hub_outlined,
                                ),
                                SizedBox(height: 16),
                                FeatureCard(
                                  title: '3DGS 管线预留',
                                  description: '可对接 COLMAP 位姿恢复、3D Gaussian Splatting 训练与模型导出。',
                                  icon: Icons.view_in_ar_outlined,
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
