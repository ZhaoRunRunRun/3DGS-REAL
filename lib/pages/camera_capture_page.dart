import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/capture_photo.dart';

class CameraCaptureResult {
  const CameraCaptureResult({required this.photos, required this.cancelled});
  final List<CapturePhoto> photos;
  final bool cancelled;
}

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key, required this.targetCount});
  final int targetCount;

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  final List<CapturePhoto> _photos = [];
  bool _isCapturing = false;
  String _status = '初始化相机...';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(camera, ResolutionPreset.high);
      await _controller!.initialize();

      if (!mounted) return;
      setState(() => _status = '围绕物体旋转拍摄 ${widget.targetCount} 张照片');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = '相机初始化失败: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final image = await _controller!.takePicture();
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/capture_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(image.path).copy(targetPath);

      final angle = (_photos.length * 360.0 / widget.targetCount);
      final photo = CapturePhoto(
        id: 'capture_${_photos.length}',
        name: 'capture_${_photos.length + 1}.jpg',
        path: targetPath,
        angle: angle,
        qualityScore: 0.85,
        source: 'camera',
      );

      setState(() {
        _photos.add(photo);
        _status = '已拍摄 ${_photos.length}/${widget.targetCount}';
      });

      if (_photos.length >= widget.targetCount) {
        _complete();
      }
    } catch (e) {
      setState(() => _status = '拍摄失败: $e');
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  void _complete() {
    Navigator.of(context).pop(CameraCaptureResult(photos: _photos, cancelled: false));
  }

  void _cancel() {
    Navigator.of(context).pop(const CameraCaptureResult(photos: [], cancelled: true));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _controller?.value.isInitialized == true
            ? Stack(
                children: [
                  Positioned.fill(child: CameraPreview(_controller!)),
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_status, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _cancel,
                          icon: const Icon(Icons.close, color: Colors.white, size: 32),
                        ),
                        FloatingActionButton.large(
                          onPressed: _isCapturing ? null : _capturePhoto,
                          child: const Icon(Icons.camera),
                        ),
                        IconButton(
                          onPressed: _photos.isEmpty ? null : _complete,
                          icon: const Icon(Icons.check, color: Colors.white, size: 32),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(child: Text(_status, style: const TextStyle(color: Colors.white))),
      ),
    );
  }
}
