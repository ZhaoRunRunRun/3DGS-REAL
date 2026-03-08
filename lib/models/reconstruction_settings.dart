class ReconstructionSettings {
  const ReconstructionSettings({
    required this.iterations,
    required this.enableColmap,
    required this.enableQualityFilter,
    required this.exportSplat,
    required this.exportPly,
    required this.exportGlb,
    required this.serverEndpoint,
  });

  final int iterations;
  final bool enableColmap;
  final bool enableQualityFilter;
  final bool exportSplat;
  final bool exportPly;
  final bool exportGlb;
  final String serverEndpoint;

  ReconstructionSettings copyWith({
    int? iterations,
    bool? enableColmap,
    bool? enableQualityFilter,
    bool? exportSplat,
    bool? exportPly,
    bool? exportGlb,
    String? serverEndpoint,
  }) {
    return ReconstructionSettings(
      iterations: iterations ?? this.iterations,
      enableColmap: enableColmap ?? this.enableColmap,
      enableQualityFilter: enableQualityFilter ?? this.enableQualityFilter,
      exportSplat: exportSplat ?? this.exportSplat,
      exportPly: exportPly ?? this.exportPly,
      exportGlb: exportGlb ?? this.exportGlb,
      serverEndpoint: serverEndpoint ?? this.serverEndpoint,
    );
  }

  static const defaults = ReconstructionSettings(
    iterations: 30000,
    enableColmap: true,
    enableQualityFilter: true,
    exportSplat: true,
    exportPly: true,
    exportGlb: false,
    serverEndpoint: 'https://example.com/api/reconstruction/jobs',
  );
}
