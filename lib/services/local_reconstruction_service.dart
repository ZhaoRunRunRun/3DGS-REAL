import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/capture_photo.dart';
import '../models/reconstruction_settings.dart';

class LocalReconstructionService {
  const LocalReconstructionService();

  Future<String> executeReconstruction({
    required List<CapturePhoto> photos,
    required ReconstructionSettings settings,
  }) async {
    final workDir = await _prepareWorkspace(photos);
    
    if (settings.enableColmap) {
      await _runColmap(workDir);
    }
    
    await _run3DGS(workDir, settings.iterations);
    
    return workDir;
  }

  Future<String> _prepareWorkspace(List<CapturePhoto> photos) async {
    final tempDir = await getTemporaryDirectory();
    final workDir = '${tempDir.path}/reconstruction_${DateTime.now().millisecondsSinceEpoch}';
    final imagesDir = '$workDir/images';
    
    await Directory(imagesDir).create(recursive: true);
    
    for (var i = 0; i < photos.length; i++) {
      final photo = photos[i];
      if (await File(photo.path).exists()) {
        await File(photo.path).copy('$imagesDir/${photo.name}');
      }
    }
    
    return workDir;
  }

  Future<void> _runColmap(String workDir) async {
    final result = await Process.run(
      'colmap',
      ['automatic_reconstructor', '--workspace_path', workDir, '--image_path', '$workDir/images'],
      workingDirectory: workDir,
    );
    
    if (result.exitCode != 0) {
      throw Exception('COLMAP failed: ${result.stderr}');
    }
  }

  Future<void> _run3DGS(String workDir, int iterations) async {
    final result = await Process.run(
      'python',
      ['train.py', '-s', workDir, '--iterations', iterations.toString()],
      workingDirectory: workDir,
    );
    
    if (result.exitCode != 0) {
      throw Exception('3DGS training failed: ${result.stderr}');
    }
  }
}
