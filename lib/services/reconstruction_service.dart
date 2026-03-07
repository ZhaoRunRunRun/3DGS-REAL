import '../models/reconstruction_mode.dart';

class ReconstructionService {
  const ReconstructionService();

  Future<String> startJob({
    required ReconstructionMode mode,
    required int imageCount,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return '${mode.name}_job_$imageCount';
  }
}
