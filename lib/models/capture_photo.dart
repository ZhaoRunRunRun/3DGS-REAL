class CapturePhoto {
  const CapturePhoto({
    required this.id,
    required this.name,
    required this.path,
    required this.angle,
    required this.qualityScore,
    required this.source,
  });

  final String id;
  final String name;
  final String path;
  final double angle;
  final double qualityScore;
  final String source;

  bool get isQualified => qualityScore >= 0.7;
}
