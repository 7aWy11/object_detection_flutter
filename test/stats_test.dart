import 'package:flutter_test/flutter_test.dart';
import 'package:object_detection_flutter/object_detection_flutter.dart';

void main() {
  group('Stats Tests', () {
    test('Create Stats instance', () {
      final stats = Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      );

      expect(stats.totalPredictTime, 100);
      expect(stats.inferenceTime, 50);
      expect(stats.preProcessingTime, 30);
      expect(stats.totalElapsedTime, 0);
    });

    test('Update total elapsed time', () {
      final stats = Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      );

      stats.totalElapsedTime = 150;
      expect(stats.totalElapsedTime, 150);
    });

    test('ToString representation', () {
      final stats = Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      );

      stats.totalElapsedTime = 150;

      expect(
        stats.toString(),
        'Stats(totalPredictTime: 100, inferenceTime: 50, preProcessingTime: 30, totalElapsedTime: 150)',
      );
    });

    test('Create Stats with zero times', () {
      final stats = Stats(
        totalPredictTime: 0,
        inferenceTime: 0,
        preProcessingTime: 0,
      );

      expect(stats.totalPredictTime, 0);
      expect(stats.inferenceTime, 0);
      expect(stats.preProcessingTime, 0);
      expect(stats.totalElapsedTime, 0);
    });

    test('Create Stats with large times', () {
      final stats = Stats(
        totalPredictTime: 1000000,
        inferenceTime: 500000,
        preProcessingTime: 300000,
      );

      expect(stats.totalPredictTime, 1000000);
      expect(stats.inferenceTime, 500000);
      expect(stats.preProcessingTime, 300000);
      expect(stats.totalElapsedTime, 0);
    });
  });
}
