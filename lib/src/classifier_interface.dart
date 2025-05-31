import 'dart:typed_data';
import 'package:image/image.dart' as imageLib;
import 'recognition.dart';

/// Enum to identify different model types
enum ModelType {
  OBJECT_DETECTION,
  CLASSIFICATION,
  YOLOV5,
  UNKNOWN,
  FACE_DETECTION,
  POSE_ESTIMATION,
  SEGMENTATION,
}

/// Abstract class defining the interface for model classification
abstract class ModelClassifier {
  /// Get the interpreter instance
  dynamic get interpreter;

  /// Get the labels list
  List<String>? get labels;

  /// Get the model type
  ModelType get modelType;

  /// Get the output tensor shapes
  List<List<int>>? get outputShapes;

  /// Get the input tensor types
  List<int>? get inputTypes;

  /// Get the output tensor types
  List<int>? get outputTypes;

  /// Get the input tensor shape
  List<int>? get inputShape;

  /// Load the model from the given path
  Future<void> loadModel({String? modelPath});

  /// Load labels from the given path
  Future<void> loadLabels({String? labelsPath});

  /// Pre-process the input image
  Uint8List preprocessImage(imageLib.Image image);

  /// Run prediction on the input image
  Map<String, dynamic> predict(imageLib.Image image);

  /// Run object detection model
  List<Recognition> runObjectDetection(
      Uint8List inputBuffer, imageLib.Image image);

  /// Run classification model
  List<Recognition> runClassification(
      Uint8List inputBuffer, imageLib.Image image);

  /// Run YOLOv5 detection model
  List<Recognition> runYolov5Detection(
      Uint8List inputBuffer, imageLib.Image image);

  /// Run face detection model
  List<Recognition> runFaceDetection(
      Uint8List inputBuffer, imageLib.Image image);

  /// Run pose estimation model
  List<Recognition> runPoseEstimation(
      Uint8List inputBuffer, imageLib.Image image);

  /// Run segmentation model
  List<Recognition> runSegmentation(
      Uint8List inputBuffer, imageLib.Image image);

  /// Close the interpreter
  void close();
}