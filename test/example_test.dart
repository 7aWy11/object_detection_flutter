import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as imageLib;
import 'package:object_detection_flutter/object_detection_flutter.dart';
import 'mocks/mock_path_provider.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockPathProvider.setupMockPathProvider();

  // Skip tests that require TensorFlow Lite on unsupported platforms
  final bool skipTFLiteTests =
      kIsWeb || (defaultTargetPlatform == TargetPlatform.windows);

  group('Example Tests', () {
    late Detector detector;

    setUp(() {
      detector = Detector();
    });

    test('Complete object detection workflow', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      // Initialize detector
      await detector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );
      expect(detector.isModelLoaded, true);

      // Run detection
      final image = imageLib.Image(width: 300, height: 300);
      final result = await detector.detect(imageLib.encodeJpg(image));
      expect(result, isA<Map<String, dynamic>>());
      expect(result['recognitions'], isA<List>());
      expect(result['stats'], isA<Stats>());
      expect(result['error'], isNull);

      // Cleanup
      detector.dispose();
      expect(detector.isModelLoaded, false);
    });

    test('Error handling in detection workflow', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      // Try to initialize with invalid paths
      expect(
        () => detector.initialize(
          modelPath: 'invalid/path/model.tflite',
          labelsPath: 'invalid/path/labels.txt',
        ),
        throwsA(isA<FlutterError>()), // Changed to FlutterError
      );
      expect(detector.isModelLoaded, false);
    });

    test('Multiple detections in sequence', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      await detector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );

      // Run multiple detections
      for (int i = 0; i < 3; i++) {
        final image = imageLib.Image(width: 300, height: 300);
        final result = await detector.detect(imageLib.encodeJpg(image));
        expect(result, isA<Map<String, dynamic>>());
        expect(result['recognitions'], isA<List>());
        expect(result['stats'], isA<Stats>());
        expect(result['error'], isNull);
      }

      detector.dispose();
    });

    test('Non-TensorFlow functionality works on all platforms', () {
      // Test basic object creation and methods that don't require TensorFlow
      expect(detector.isModelLoaded, false);
      expect(detector.isDetecting, false);
      
      // This should work on all platforms
      final recognition = Recognition(
        id: 1,
        label: 'test',
        score: 0.5,
        location: const Rect.fromLTWH(0, 0, 100, 100),
      );
      
      expect(recognition.id, 1);
      expect(recognition.label, 'test');
      expect(recognition.score, 0.5);
    });
  });
}