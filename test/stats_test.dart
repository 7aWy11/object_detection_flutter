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

    test('Create Stats with negative times throws error', () {
      expect(
        () => Stats(
          totalPredictTime: -100,
          inferenceTime: 50,
          preProcessingTime: 30,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => Stats(
          totalPredictTime: 100,
          inferenceTime: -50,
          preProcessingTime: 30,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => Stats(
          totalPredictTime: 100,
          inferenceTime: 50,
          preProcessingTime: -30,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Set negative total elapsed time throws error', () {
      final stats = Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      );

      expect(
        () => stats.totalElapsedTime = -150,
        throwsA(isA<AssertionError>()),
      );
    });

    test('Equality comparison', () {
      final stats1 = Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      );
      stats1.totalElapsedTime = 150;

      final stats2 = Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      );
      stats2.totalElapsedTime = 150;

      final stats3 = Stats(
        totalPredictTime: 200,
        inferenceTime: 100,
        preProcessingTime: 60,
      );
      stats3.totalElapsedTime = 300;

      expect(stats1, equals(stats2));
      expect(stats1, isNot(equals(stats3)));
      expect(stats1.hashCode, equals(stats2.hashCode));
      expect(stats1.hashCode, isNot(equals(stats3.hashCode)));
    });

    test('Copy with method', () {
      final original = Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      );
      original.totalElapsedTime = 150;

      final copy = original.copyWith(
        totalPredictTime: 200,
        inferenceTime: 100,
        preProcessingTime: 60,
        totalElapsedTime: 300,
      );

      expect(copy.totalPredictTime, 200);
      expect(copy.inferenceTime, 100);
      expect(copy.preProcessingTime, 60);
      expect(copy.totalElapsedTime, 300);

      // Original should remain unchanged
      expect(original.totalPredictTime, 100);
      expect(original.inferenceTime, 50);
      expect(original.preProcessingTime, 30);
      expect(original.totalElapsedTime, 150);
    });

    test('Copy with partial updates', () {
      final original = Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      );
      original.totalElapsedTime = 150;

      final copy = original.copyWith(
        totalPredictTime: 200,
        totalElapsedTime: 300,
      );

      expect(copy.totalPredictTime, 200);
      expect(copy.inferenceTime, 50); // Unchanged
      expect(copy.preProcessingTime, 30); // Unchanged
      expect(copy.totalElapsedTime, 300);
    });
  });
}
