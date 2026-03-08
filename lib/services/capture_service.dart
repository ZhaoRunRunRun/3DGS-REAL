import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/capture_photo.dart';
import '../pages/camera_capture_page.dart';

typedef CameraPreparation = ({
  bool cameraAvailable,
  bool usingFallback,
  String message,
});

class CaptureService {
  const CaptureService();

  Future<CameraPreparation> prepareCameraGuide() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      return (
        cameraAvailable: false,
        usingFallback: true,
        message: '未拿到相机权限，先使用演示采集流程。',
      );
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return (
          cameraAvailable: false,
          usingFallback: true,
          message: '没有检测到可用相机，先使用演示采集流程。',
        );
      }

      final preferredCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      return (
        cameraAvailable: true,
        usingFallback: false,
        message: '已就绪：检测到 ${preferredCamera.name.isEmpty ? '可用相机' : preferredCamera.name}',
      );
    } catch (_) {
      return (
        cameraAvailable: false,
        usingFallback: true,
        message: '相机能力检查失败，已切回演示采集流程。',
      );
    }
  }

  Future<List<CapturePhoto>> startGuidedCapture(BuildContext context, {int count = 48}) async {
    final result = await Navigator.of(context).push<CameraCaptureResult>(
      MaterialPageRoute(builder: (_) => CameraCapturePage(targetCount: count)),
    );

    if (result == null || result.cancelled || result.photos.isEmpty) {
      return generateDemoCapture(count: count);
    }

    return result.photos;
  }

  Future<List<CapturePhoto>> generateDemoCapture({required int count}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final random = Random(count * 99);
    return List.generate(count, (index) {
      final angle = (360 / count) * index;
      final score = 0.72 + random.nextDouble() * 0.25;
      return CapturePhoto(
        id: 'capture_$index',
        name: 'capture_${index + 1}.jpg',
        path: '/mock/capture_${index + 1}.jpg',
        angle: angle,
        qualityScore: score.clamp(0, 1),
        source: 'camera',
      );
    });
  }
}
