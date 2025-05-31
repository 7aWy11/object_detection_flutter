import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as imageLib;
import 'package:object_detection_flutter/src/detector.dart';
import 'package:object_detection_flutter/src/stats.dart';
import 'mocks/mock_path_provider.dart';
import 'package:flutter/foundation.dart'
    show FlutterError, TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:object_detection_flutter/src/recognition.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockPathProvider.setupMockPathProvider();

  // Skip tests that require TensorFlow Lite on unsupported platforms
  final bool skipTFLiteTests =
      kIsWeb || (defaultTargetPlatform == TargetPlatform.windows);

  group('Detector Tests', () {
    late Detector detector;

    setUp(() {
      detector = Detector();
    });

    tearDown(() {
      detector.dispose();
    });

    test('Initial state', () {
      expect(detector.isModelLoaded, false);
      expect(detector.isDetecting, false);
    });

    test('Initialize detector with valid paths', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      await detector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );
      expect(detector.isModelLoaded, true);
    });

    test('Initialize detector with invalid paths throws error', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      expect(
        () => detector.initialize(
          modelPath: 'invalid/path/model.tflite',
          labelsPath: 'invalid/path/labels.txt',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Detect with valid image', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      await detector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );

      final image = imageLib.Image(width: 300, height: 300);
      final result = await detector.detect(imageLib.encodeJpg(image));
      expect(result, isA<Map<String, dynamic>>());
      expect(result['recognitions'], isA<List>());
      expect(result['stats'], isA<Stats>());
      expect(result['error'], isNull);
    });

    test('Detect with invalid image throws error', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      await detector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );

      expect(
        () => detector.detect(Uint8List(0)),
        throwsA(isA<Exception>()),
      );
    });

    test('Detect with corrupted image data throws error', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      await detector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );

      expect(
        () => detector.detect(Uint8List.fromList([1, 2, 3, 4, 5])),
        throwsA(isA<Exception>()),
      );
    });

    test('Concurrent detection handling', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      await detector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );

      final image = imageLib.Image(width: 300, height: 300);
      final imageData = imageLib.encodeJpg(image);

      // Start multiple detections
      final futures = List.generate(
        3,
        (_) => detector.detect(imageData),
      );

      // Wait for all detections to complete
      final results = await Future.wait(futures);

      // Verify all detections completed successfully
      for (final result in results) {
        expect(result['error'], isNull);
        expect(result['recognitions'], isA<List>());
        expect(result['stats'], isA<Stats>());
      }
    });

    test('Dispose detector', () async {
      if (skipTFLiteTests) {
        print('Skipping TensorFlow Lite test on ${defaultTargetPlatform}');
        return;
      }
      await detector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );

      detector.dispose();
      expect(detector.isModelLoaded, false);
    });

    test('Dispose uninitialized detector', () {
      expect(() => detector.dispose(), returnsNormally);
    });
  });
}
