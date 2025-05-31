import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'classifier.dart';
import 'recognition.dart';
import 'stats.dart';
import 'isolate_utils.dart';
import 'detector_interface.dart';
import 'classifier_interface.dart';

/// Main detector class that handles model loading and inference
class Detector implements ObjectDetector {
  /// Instance of the classifier
  ModelClassifier? _classifier;

  /// Instance of isolate utilities
  IsolateUtils? _isolateUtils;

  /// Flag to track if model is loaded
  bool _isModelLoaded = false;

  /// Flag to track if detection is in progress
  bool _isDetecting = false;

  /// Constructor
  Detector({ModelClassifier? classifier}) {
    _classifier = classifier;
  }

  @override
  bool get isModelLoaded => _isModelLoaded;

  @override
  bool get isDetecting => _isDetecting;

  @override
  Future<void> initialize({
    required String modelPath,
    required String labelsPath,
  }) async {
    try {
      // Load model and labels
      _classifier ??= Classifier();
      await _classifier!.loadModel(modelPath: modelPath);
      await _classifier!.loadLabels(labelsPath: labelsPath);

      // Initialize isolate
      _isolateUtils = IsolateUtils();
      await _isolateUtils!.start();

      _isModelLoaded = true;
    } catch (e) {
      _isModelLoaded = false;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> detect(Uint8List imageData) async {
    if (!_isModelLoaded ||
        _isDetecting ||
        _classifier == null ||
        _isolateUtils?.sendPort == null) {
      throw Exception('Detector not properly initialized');
    }

    _isDetecting = true;

    try {
      final responsePort = ReceivePort();

      // Send data to isolate
      _isolateUtils!.sendPort!.send(IsolateData(
        imageData: imageData,
        interpreterAddress: _classifier!.interpreter!.address,
        labels: _classifier!.labels!,
        responsePort: responsePort.sendPort,
        imageWidth: 0, // These will be updated when image is decoded
        imageHeight: 0,
      ));

      // Get results from isolate
      final results = await responsePort.first;

      return results;
    } catch (e) {
      return {
        "recognitions": <Recognition>[],
        "stats": null,
        "error": e.toString()
      };
    } finally {
      _isDetecting = false;
    }
  }

  @override
  void dispose() {
    _isolateUtils?.stop();
    _classifier?.close();
    _isModelLoaded = false;
  }
}
