import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/capture_photo.dart';

class PhotoOrbitChart extends StatelessWidget {
  const PhotoOrbitChart({
    super.key,
    required this.photos,
  });

  final List<CapturePhoto> photos;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(220),
      painter: _PhotoOrbitChartPainter(photos),
    );
  }
}

class _PhotoOrbitChartPainter extends CustomPainter {
  _PhotoOrbitChartPainter(this.photos);

  final List<CapturePhoto> photos;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * 0.35;
    final ringPaint = Paint()
      ..color = const Color(0xFFCFD8CF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final objectPaint = Paint()..color = const Color(0xFF073B3A);

    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.36, objectPaint);

    for (final photo in photos) {
      final radians = photo.angle * math.pi / 180;
      final point = Offset(
        center.dx + math.cos(radians - math.pi / 2) * radius,
        center.dy + math.sin(radians - math.pi / 2) * radius,
      );
      final marker = Paint()
        ..color = photo.isQualified ? const Color(0xFF6BBF59) : const Color(0xFFF25F5C);
      canvas.drawCircle(point, 7, marker);
    }
  }

  @override
  bool shouldRepaint(covariant _PhotoOrbitChartPainter oldDelegate) {
    return oldDelegate.photos != photos;
  }
}
