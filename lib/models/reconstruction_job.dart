import 'capture_photo.dart';
import 'reconstruction_mode.dart';

enum ReconstructionJobStatus { draft, queued, processing, done, failed }

class ReconstructionJob {
  const ReconstructionJob({
    required this.id,
    required this.name,
    required this.mode,
    required this.status,
    required this.photos,
    required this.progress,
    required this.createdAt,
    required this.message,
    this.previewUrl,
  });

  final String id;
  final String name;
  final ReconstructionMode mode;
  final ReconstructionJobStatus status;
  final List<CapturePhoto> photos;
  final double progress;
  final DateTime createdAt;
  final String message;
  final String? previewUrl;

  ReconstructionJob copyWith({
    String? id,
    String? name,
    ReconstructionMode? mode,
    ReconstructionJobStatus? status,
    List<CapturePhoto>? photos,
    double? progress,
    DateTime? createdAt,
    String? message,
    String? previewUrl,
  }) {
    return ReconstructionJob(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      photos: photos ?? this.photos,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      message: message ?? this.message,
      previewUrl: previewUrl ?? this.previewUrl,
    );
  }
}
