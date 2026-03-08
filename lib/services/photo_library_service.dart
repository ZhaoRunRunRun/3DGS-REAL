import 'dart:math';

import 'package:file_picker/file_picker.dart';

import '../models/capture_photo.dart';

typedef PhotoImportResult = ({
  List<CapturePhoto> photos,
  String message,
  bool usedFallback,
});

class PhotoLibraryService {
  const PhotoLibraryService();

  Future<PhotoImportResult> importOrbitPhotos({int demoCount = 36}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) {
        return (
          photos: const [],
          message: '已取消相册导入。',
          usedFallback: false,
        );
      }

      final files = result.files
          .where((file) => file.path != null && file.path!.isNotEmpty)
          .toList()
        ..sort((left, right) => left.name.compareTo(right.name));

      if (files.isEmpty) {
        return (
          photos: const [],
          message: '所选图片暂时无法读取本地路径，请改用桌面端文件系统选择。',
          usedFallback: false,
        );
      }

      final photos = List.generate(files.length, (index) {
        final file = files[index];
        final angle = (360 / files.length) * index;
        final score = _qualityScoreFor(file.name, index);
        return CapturePhoto(
          id: 'gallery_$index',
          name: file.name,
          path: file.path!,
          angle: angle,
          qualityScore: score,
          source: 'gallery',
        );
      });

      return (
        photos: photos,
        message: '相册导入完成：共 ${photos.length} 张，已按文件名顺序映射环绕角度。',
        usedFallback: false,
      );
    } catch (_) {
      final photos = await importDemoPhotos(count: demoCount);
      return (
        photos: photos,
        message: '当前平台文件选择不可用，已回退到 ${photos.length} 张演示照片。',
        usedFallback: true,
      );
    }
  }

  Future<List<CapturePhoto>> importDemoPhotos({required int count}) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final random = Random(count);
    return List.generate(count, (index) {
      final angle = (360 / count) * index;
      final score = 0.68 + random.nextDouble() * 0.3;
      return CapturePhoto(
        id: 'photo_$index',
        name: 'orbit_${index + 1}.jpg',
        path: '/mock/orbit_${index + 1}.jpg',
        angle: angle,
        qualityScore: score.clamp(0, 1),
        source: 'gallery',
      );
    });
  }

  double _qualityScoreFor(String name, int index) {
    final seed = name.codeUnits.fold<int>(index + 17, (value, unit) => value + unit);
    final random = Random(seed);
    return (0.65 + random.nextDouble() * 0.33).clamp(0, 1);
  }
}
