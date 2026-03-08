import 'dart:io';

import 'package:file_picker/file_picker.dart';

class ModelExportService {
  const ModelExportService();

  Future<String?> exportModel({
    required String workDir,
    required List<String> formats,
  }) async {
    final outputDir = await FilePicker.platform.getDirectoryPath();
    if (outputDir == null) return null;

    for (final format in formats) {
      await _exportFormat(workDir, outputDir, format);
    }

    return outputDir;
  }

  Future<void> _exportFormat(String workDir, String outputDir, String format) async {
    final sourceFile = '$workDir/output/point_cloud.$format';
    final targetFile = '$outputDir/model_${DateTime.now().millisecondsSinceEpoch}.$format';

    if (await File(sourceFile).exists()) {
      await File(sourceFile).copy(targetFile);
    }
  }

  Future<List<String>> getAvailableFormats(String workDir) async {
    final formats = <String>[];
    final outputDir = Directory('$workDir/output');

    if (!await outputDir.exists()) return formats;

    await for (final entity in outputDir.list()) {
      if (entity is File) {
        final ext = entity.path.split('.').last.toLowerCase();
        if (['splat', 'ply', 'glb'].contains(ext)) {
          formats.add(ext);
        }
      }
    }

    return formats;
  }
}
