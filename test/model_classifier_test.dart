import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:object_detection_flutter/object_detection_flutter.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'test_utils.dart';

/// Mock implementation of ModelClassifier for testing
class MockModelClassifier implements ModelClassifier {
  Interpreter? _interpreter;
  List<String>? _labels;
  bool _isClosed = false;

  @override
  Interpreter? get interpreter => _interpreter;

  @override
  List<String>? get labels => _labels;

  @override
  Future<void> loadModel({String? modelPath}) async {
    _interpreter = null; // Mock interpreter
  }

  @override
  Future<void> loadLabels({String? labelsPath}) async {
    _labels = ['person', 'car', 'dog'];
  }

  @override
  Uint8List preprocessImage(imageLib.Image image) {
    return Uint8List.fromList([1, 2, 3, 4]);
  }

  @override
  Map<String, dynamic> predict(imageLib.Image image) {
    return {
      "recognitions": <Recognition>[],
      "stats": Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      )
    };
  }

  @override
  List<Recognition> runObjectDetection(
      Uint8List inputBuffer, imageLib.Image image) {
    return [];
  }

  @override
  List<Recognition> runClassification(
      Uint8List inputBuffer, imageLib.Image image) {
    return [];
  }

  @override
  List<Recognition> runYolov5Detection(
      Uint8List inputBuffer, imageLib.Image image) {
    return [];
  }

  @override
  void close() {
    _isClosed = true;
    _interpreter = null;
  }
}

void main() {
  group('ModelClassifier Interface Tests', () {
    late MockModelClassifier classifier;

    setUp(() {
      classifier = MockModelClassifier();
    });

    test('Initial state', () {
      expect(classifier.interpreter, null);
      expect(classifier.labels, null);
    });

    test('Load model', () async {
      await classifier.loadModel();
      expect(classifier.interpreter, null); // Mock implementation returns null
    });

    test('Load labels', () async {
      await classifier.loadLabels();
      expect(classifier.labels, isNotNull);
      expect(classifier.labels!.length, 3);
      expect(classifier.labels![0], 'person');
      expect(classifier.labels![1], 'car');
      expect(classifier.labels![2], 'dog');
    });

    test('Preprocess image', () {
      final image = imageLib.Image(width: 100, height: 100);
      final processedImage = classifier.preprocessImage(image);

      expect(processedImage, isA<Uint8List>());
      expect(processedImage.length, 4);
    });

    test('Predict', () {
      final image = imageLib.Image(width: 100, height: 100);
      final results = classifier.predict(image);

      expect(results, isA<Map<String, dynamic>>());
      expect(results['recognitions'], isA<List<Recognition>>());
      expect(results['stats'], isA<Stats>());

      final stats = results['stats'] as Stats;
      expect(stats.totalPredictTime, 100);
      expect(stats.inferenceTime, 50);
      expect(stats.preProcessingTime, 30);
    });

    test('Run object detection', () {
      final inputBuffer = Uint8List.fromList([1, 2, 3, 4]);
      final image = imageLib.Image(width: 100, height: 100);
      final results = classifier.runObjectDetection(inputBuffer, image);

      expect(results, isA<List<Recognition>>());
      expect(results.isEmpty, true);
    });

    test('Run classification', () {
      final inputBuffer = Uint8List.fromList([1, 2, 3, 4]);
      final image = imageLib.Image(width: 100, height: 100);
      final results = classifier.runClassification(inputBuffer, image);

      expect(results, isA<List<Recognition>>());
      expect(results.isEmpty, true);
    });

    test('Run YOLOv5 detection', () {
      final inputBuffer = Uint8List.fromList([1, 2, 3, 4]);
      final image = imageLib.Image(width: 100, height: 100);
      final results = classifier.runYolov5Detection(inputBuffer, image);

      expect(results, isA<List<Recognition>>());
      expect(results.isEmpty, true);
    });

    test('Close', () {
      classifier.close();
      expect(classifier.interpreter, null);
    });
  });
}
