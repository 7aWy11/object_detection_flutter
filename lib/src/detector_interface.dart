import 'dart:typed_data';
import 'recognition.dart';
import 'stats.dart';

/// Abstract class defining the interface for object detection
abstract class ObjectDetector {
  /// Initialize the detector with model and labels
  Future<void> initialize({
    required String modelPath,
    required String labelsPath,
  });

  /// Run detection on an image
  Future<Map<String, dynamic>> detect(Uint8List imageData);

  /// Get the current model loaded status
  bool get isModelLoaded;

  /// Get the current detection status
  bool get isDetecting;

  /// Dispose resources
  void dispose();
}

/// Abstract class for custom detection results
abstract class DetectionResult {
  /// List of detected objects
  List<Recognition> get recognitions;

  /// Performance statistics
  Stats? get stats;

  /// Any error that occurred during detection
  String? get error;
}
