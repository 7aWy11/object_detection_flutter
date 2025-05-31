import 'dart:typed_data';
import 'dart:io' show Platform;
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockPathProvider.setupMockPathProvider();

  // Check for environment variable to force enable TensorFlow Lite tests
  final forceEnableTFLite = Platform.environment['ENABLE_TFLITE_TESTS'] == 'true';
  
  // Skip tests unless specifically enabled for mobile testing
  final bool skipTFLiteTests = !forceEnableTFLite && (
      kIsWeb || 
      Platform.isWindows || 
      (defaultTargetPlatform == TargetPlatform.windows)
  );

  group('Classifier Tests', () {
    late Classifier classifier;

    setUp(() {
      classifier = Classifier();
    });

    test('Initial state', () {
      expect(classifier.interpreter, isNull);
      expect(classifier.labels, isNull);
    });

    test('Load model and labels', () async {
      if (skipTFLiteTests) {
        markTestSkipped('TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.');
        return;
      }
      
      await classifier.loadModel(modelPath: 'assets/model.tflite');
      await classifier.loadLabels(labelsPath: 'assets/labels.txt');

      expect(classifier.interpreter, isNotNull);
      expect(classifier.labels, isNotNull);
      expect(classifier.labels!.length, 29); // A-Z, Delete, Nothing, Space
      expect(classifier.labels![0], 'A');
      expect(classifier.labels![25], 'Z');
      expect(classifier.labels![26], 'Delete');
      expect(classifier.labels![27], 'Nothing');
      expect(classifier.labels![28], 'Space');
    }, skip: skipTFLiteTests ? 'TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.' : null);

    test('Load invalid model throws error', () async {
      if (skipTFLiteTests) {
        markTestSkipped('TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.');
        return;
      }
      
      expect(
        () => classifier.loadModel(modelPath: 'invalid/path/model.tflite'),
        throwsA(isA<Exception>()),
      );
    }, skip: skipTFLiteTests ? 'TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.' : null);

    test('Load invalid labels throws error', () async {
      if (skipTFLiteTests) {
        markTestSkipped('TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.');
        return;
      }
      
      expect(
        () => classifier.loadLabels(labelsPath: 'invalid/path/labels.txt'),
        throwsA(isA<Exception>()),
      );
    }, skip: skipTFLiteTests ? 'TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.' : null);

    test('Predict with valid image', () async {
      if (skipTFLiteTests) {
        markTestSkipped('TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.');
        return;
      }
      
      await classifier.loadModel(modelPath: 'assets/model.tflite');
      await classifier.loadLabels(labelsPath: 'assets/labels.txt');

      final image = imageLib.Image(width: 300, height: 300);
      final result = classifier.predict(image);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['recognitions'], isA<List<Recognition>>());
      expect(result['stats'], isA<Stats>());
    }, skip: skipTFLiteTests ? 'TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.' : null);

    test('Run object detection', () async {
      if (skipTFLiteTests) {
        markTestSkipped('TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.');
        return;
      }
      
      await classifier.loadModel(modelPath: 'assets/model.tflite');
      await classifier.loadLabels(labelsPath: 'assets/labels.txt');

      final image = imageLib.Image(width: 300, height: 300);
      final inputBuffer = classifier.preprocessImage(image);
      final result = classifier.runObjectDetection(inputBuffer, image);
      expect(result, isA<List<Recognition>>());
    }, skip: skipTFLiteTests ? 'TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.' : null);

    test('Run classification', () async {
      if (skipTFLiteTests) {
        markTestSkipped('TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.');
        return;
      }
      
      await classifier.loadModel(modelPath: 'assets/model.tflite');
      await classifier.loadLabels(labelsPath: 'assets/labels.txt');

      final image = imageLib.Image(width: 300, height: 300);
      final inputBuffer = classifier.preprocessImage(image);
      final result = classifier.runClassification(inputBuffer, image);
      expect(result, isA<List<Recognition>>());
    }, skip: skipTFLiteTests ? 'TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.' : null);

    test('Run YOLOv5 detection', () async {
      if (skipTFLiteTests) {
        markTestSkipped('TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.');
        return;
      }
      
      await classifier.loadModel(modelPath: 'assets/model.tflite');
      await classifier.loadLabels(labelsPath: 'assets/labels.txt');

      final image = imageLib.Image(width: 300, height: 300);
      final inputBuffer = classifier.preprocessImage(image);
      final result = classifier.runYolov5Detection(inputBuffer, image);
      expect(result, isA<List<Recognition>>());
    }, skip: skipTFLiteTests ? 'TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.' : null);

    test('Close classifier', () async {
      if (skipTFLiteTests) {
        markTestSkipped('TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.');
        return;
      }
      
      await classifier.loadModel(modelPath: 'assets/model.tflite');
      await classifier.loadLabels(labelsPath: 'assets/labels.txt');

      classifier.close();
      expect(classifier.interpreter, isNull);
      expect(classifier.labels, isNull);
    }, skip: skipTFLiteTests ? 'TensorFlow Lite not supported on Windows/Web. Set ENABLE_TFLITE_TESTS=true to force run.' : null);

    // Tests that should work on ALL platforms
    test('Classifier initialization (platform-independent)', () {
      final classifier = Classifier();
      expect(classifier.interpreter, isNull);
      expect(classifier.labels, isNull);
    });

    test('Image preprocessing (platform-independent)', () {
      final classifier = Classifier();
      final image = imageLib.Image(width: 100, height: 100);
      
      // This should work without TensorFlow
      expect(() => classifier.preprocessImage(image), returnsNormally);
    });
  });
}