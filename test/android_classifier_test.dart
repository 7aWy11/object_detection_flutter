import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as imageLib;
import 'package:object_detection_flutter/src/classifier.dart';
import 'package:object_detection_flutter/src/classifier_interface.dart';
import 'package:object_detection_flutter/src/stats.dart';
import 'package:object_detection_flutter/src/recognition.dart';
import 'mocks/mock_path_provider.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart';

/// This test file is specifically for Android testing
/// Run with: flutter test --device-id=emulator-5554 test/android_classifier_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockPathProvider.setupMockPathProvider();

  // Force enable TensorFlow Lite tests for Android
  const bool enableTFLiteTests = true;

  group('Android Classifier Tests (TensorFlow Lite Enabled)', () {
    late Classifier classifier;

    setUp(() {
      classifier = Classifier();
    });

    test('Initial state', () {
      expect(classifier.interpreter, isNull);
      expect(classifier.labels, isNull);
    });

    test('Load model and labels on Android', () async {
      try {
        await classifier.loadModel(modelPath: 'assets/model.tflite');
        await classifier.loadLabels(labelsPath: 'assets/labels.txt');

        expect(classifier.interpreter, isNotNull);
        expect(classifier.labels, isNotNull);
        expect(classifier.labels!.length, greaterThan(0));
        
        print('✅ Model loaded successfully on Android!');
        print('📊 Labels count: ${classifier.labels!.length}');
        if (classifier.labels!.isNotEmpty) {
          print('🏷️ First label: ${classifier.labels![0]}');
        }
      } catch (e) {
        print('❌ Failed to load model on Android: $e');
        rethrow;
      }
    });

    test('Load invalid model throws error on Android', () async {
      expect(
        () => classifier.loadModel(modelPath: 'invalid/path/model.tflite'),
        throwsA(isA<Exception>()),
      );
      print('✅ Invalid model properly rejected');
    });

    test('Load invalid labels throws error on Android', () async {
      expect(
        () => classifier.loadLabels(labelsPath: 'invalid/path/labels.txt'),
        throwsA(isA<Exception>()),
      );
      print('✅ Invalid labels properly rejected');
    });

    test('Predict with valid image on Android', () async {
      try {
        await classifier.loadModel(modelPath: 'assets/model.tflite');
        await classifier.loadLabels(labelsPath: 'assets/labels.txt');

        final image = imageLib.Image(width: 300, height: 300);
        // Fill image with some pattern for better testing
        imageLib.fill(image, color: imageLib.ColorRgb8(128, 128, 128));
        
        final stopwatch = Stopwatch()..start();
        final result = classifier.predict(image);
        stopwatch.stop();

        expect(result, isA<Map<String, dynamic>>());
        expect(result['recognitions'], isA<List<Recognition>>());
        expect(result['stats'], isA<Stats>());

        final recognitions = result['recognitions'] as List<Recognition>;
        final stats = result['stats'] as Stats;

        print('✅ Prediction completed on Android!');
        print('⏱️ Total prediction time: ${stopwatch.elapsedMilliseconds}ms');
        print('📊 Stats - Inference: ${stats.inferenceTime}ms, Preprocessing: ${stats.preProcessingTime}ms');
        print('🎯 Recognitions found: ${recognitions.length}');
        
        for (int i = 0; i < recognitions.length && i < 3; i++) {
          final rec = recognitions[i];
          print('   ${i + 1}. ${rec.label} (${(rec.score * 100).toStringAsFixed(1)}%)');
        }
      } catch (e) {
        print('❌ Prediction failed on Android: $e');
        rethrow;
      }
    });

    test('Run object detection on Android', () async {
      try {
        await classifier.loadModel(modelPath: 'assets/model.tflite');
        await classifier.loadLabels(labelsPath: 'assets/labels.txt');

        final image = imageLib.Image(width: 300, height: 300);
        imageLib.fill(image, color: imageLib.ColorRgb8(255, 0, 0)); // Red image
        
        final inputBuffer = classifier.preprocessImage(image);
        expect(inputBuffer, isA<Uint8List>());
        print('✅ Image preprocessing completed - buffer size: ${inputBuffer.length}');

        final result = classifier.runObjectDetection(inputBuffer, image);
        expect(result, isA<List<Recognition>>());
        print('✅ Object detection completed - found ${result.length} objects');
      } catch (e) {
        print('❌ Object detection failed on Android: $e');
        rethrow;
      }
    });

    test('Run classification on Android', () async {
      try {
        await classifier.loadModel(modelPath: 'assets/model.tflite');
        await classifier.loadLabels(labelsPath: 'assets/labels.txt');

        final image = imageLib.Image(width: 300, height: 300);
        imageLib.fill(image, color: imageLib.ColorRgb8(0, 255, 0)); // Green image
        
        final inputBuffer = classifier.preprocessImage(image);
        final result = classifier.runClassification(inputBuffer, image);
        
        expect(result, isA<List<Recognition>>());
        print('✅ Classification completed - found ${result.length} classes');
        
        if (result.isNotEmpty) {
          final topResult = result.first;
          print('🏆 Top result: ${topResult.label} (${(topResult.score * 100).toStringAsFixed(1)}%)');
        }
      } catch (e) {
        print('❌ Classification failed on Android: $e');
        rethrow;
      }
    });

    test('Run YOLOv5 detection on Android', () async {
      try {
        await classifier.loadModel(modelPath: 'assets/model.tflite');
        await classifier.loadLabels(labelsPath: 'assets/labels.txt');

        final image = imageLib.Image(width: 300, height: 300);
        imageLib.fill(image, color: imageLib.ColorRgb8(0, 0, 255)); // Blue image
        
        final inputBuffer = classifier.preprocessImage(image);
        final result = classifier.runYolov5Detection(inputBuffer, image);
        
        expect(result, isA<List<Recognition>>());
        print('✅ YOLOv5 detection completed - found ${result.length} detections');
      } catch (e) {
        print('❌ YOLOv5 detection failed on Android: $e');
        rethrow;
      }
    });

    test('Performance test - multiple predictions on Android', () async {
      try {
        await classifier.loadModel(modelPath: 'assets/model.tflite');
        await classifier.loadLabels(labelsPath: 'assets/labels.txt');

        final times = <int>[];
        
        for (int i = 0; i < 5; i++) {
          final image = imageLib.Image(width: 300, height: 300);
          imageLib.fill(image, color: imageLib.ColorRgb8(i * 50, i * 40, i * 30));
          
          final stopwatch = Stopwatch()..start();
          final result = classifier.predict(image);
          stopwatch.stop();
          
          times.add(stopwatch.elapsedMilliseconds);
          final stats = result['stats'] as Stats;
          print('Run ${i + 1}: ${stopwatch.elapsedMilliseconds}ms (inference: ${stats.inferenceTime}ms)');
        }
        
        final avgTime = times.reduce((a, b) => a + b) / times.length;
        print('📊 Average prediction time: ${avgTime.toStringAsFixed(1)}ms');
        print('⚡ Min: ${times.reduce((a, b) => a < b ? a : b)}ms, Max: ${times.reduce((a, b) => a > b ? a : b)}ms');
        
        expect(avgTime, lessThan(5000)); // Should be less than 5 seconds
      } catch (e) {
        print('❌ Performance test failed on Android: $e');
        rethrow;
      }
    });

    test('Close classifier on Android', () async {
      try {
        await classifier.loadModel(modelPath: 'assets/model.tflite');
        await classifier.loadLabels(labelsPath: 'assets/labels.txt');

        classifier.close();
        expect(classifier.interpreter, isNull);
        expect(classifier.labels, isNull);
        print('✅ Classifier closed successfully on Android');
      } catch (e) {
        print('❌ Failed to close classifier on Android: $e');
        rethrow;
      }
    });
  });
}