/// Class to track performance statistics of object detection
class Stats {
  /// Total time taken for prediction (including preprocessing and inference)
  final int totalPredictTime;

  /// Time taken for inference only
  final int inferenceTime;

  /// Time taken for preprocessing the image
  final int preProcessingTime;

  /// Total elapsed time including communication overhead
  int totalElapsedTime = 0;

  Stats({
    required this.totalPredictTime,
    required this.inferenceTime,
    required this.preProcessingTime,
  });

  @override
  String toString() {
    return 'Stats(totalPredictTime: $totalPredictTime, inferenceTime: $inferenceTime, preProcessingTime: $preProcessingTime, totalElapsedTime: $totalElapsedTime)';
  }

  Stats copyWith({
    int? totalPredictTime,
    int? inferenceTime,
    int? preProcessingTime,
    int? totalElapsedTime,
  }) {
    final stats = Stats(
      totalPredictTime: totalPredictTime ?? this.totalPredictTime,
      inferenceTime: inferenceTime ?? this.inferenceTime,
      preProcessingTime: preProcessingTime ?? this.preProcessingTime,
    );
    stats.totalElapsedTime = totalElapsedTime ?? this.totalElapsedTime;
    return stats;
  }
}
