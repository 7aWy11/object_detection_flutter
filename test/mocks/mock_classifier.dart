import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:object_detection_flutter/src/classifier_interface.dart';
import 'package:object_detection_flutter/src/recognition.dart';
import 'package:object_detection_flutter/src/stats.dart';
import 'mock_interpreter.dart';

/// Mock implementation of the ModelClassifier interface for testing
class MockClassifier implements ModelClassifier {
  bool _isModelLoaded = false;
  bool _isLabelsLoaded = false;
  List<String>? _labels;
  MockInterpreter? _interpreter;

  @override
  Future<void> loadModel({String? modelPath}) async {
    if (modelPath?.contains('invalid') ?? true) {
      throw Exception('Failed to load model: Invalid path');
    }
    _interpreter = MockInterpreter();
    _isModelLoaded = true;
  }

  @override
  Future<void> loadLabels({String? labelsPath}) async {
    if (labelsPath?.contains('invalid') ?? true) {
      throw Exception('Failed to load labels: Invalid path');
    }
    _labels = ['person', 'car', 'dog', 'cat'];
    _isLabelsLoaded = true;
  }

  @override
  Map<String, dynamic> predict(imageLib.Image image) {
    if (!_isModelLoaded || !_isLabelsLoaded) {
      throw Exception('Model or labels not loaded');
    }

    // Return mock predictions
    return {
      'recognitions': [
        Recognition(
          id: 0,
          label: 'person',
          score: 0.95,
          location: const Rect.fromLTWH(100, 100, 200, 300),
        ),
        Recognition(
          id: 1,
          label: 'car',
          score: 0.85,
          location: const Rect.fromLTWH(300, 200, 150, 100),
        ),
      ],
      'stats': Stats(
        totalPredictTime: 100,
        inferenceTime: 50,
        preProcessingTime: 30,
      ),
    };
  }

  @override
  List<Recognition> runObjectDetection(
      Uint8List inputBuffer, imageLib.Image image) {
    return [
      Recognition(
        id: 0,
        label: 'person',
        score: 0.95,
        location: const Rect.fromLTWH(100, 100, 200, 300),
      ),
      Recognition(
        id: 1,
        label: 'car',
        score: 0.85,
        location: const Rect.fromLTWH(300, 200, 150, 100),
      ),
    ];
  }

  @override
  List<Recognition> runClassification(
      Uint8List inputBuffer, imageLib.Image image) {
    return [
      Recognition(
        id: 0,
        label: 'person',
        score: 0.95,
        location: const Rect.fromLTWH(100, 100, 200, 300),
      ),
    ];
  }

  @override
  List<Recognition> runYolov5Detection(
      Uint8List inputBuffer, imageLib.Image image) {
    return [
      Recognition(
        id: 0,
        label: 'person',
        score: 0.95,
        location: const Rect.fromLTWH(100, 100, 200, 300),
      ),
      Recognition(
        id: 1,
        label: 'car',
        score: 0.85,
        location: const Rect.fromLTWH(300, 200, 150, 100),
      ),
    ];
  }

  @override
  void close() {
    _isModelLoaded = false;
    _isLabelsLoaded = false;
    _labels = null;
    _interpreter = null;
  }

  @override
  dynamic get interpreter => _interpreter;

  @override
  List<String>? get labels => _labels;

  @override
  Uint8List preprocessImage(imageLib.Image image) {
    return Uint8List.fromList([1, 2, 3, 4]);
  }
}
