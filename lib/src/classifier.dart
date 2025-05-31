import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';

import 'recognition.dart';
import 'stats.dart';
import 'classifier_interface.dart';

class Classifier implements ModelClassifier {
  /// Instance of Interpreter
  dynamic _interpreter;

  /// Labels file loaded as list
  List<String>? _labels;

  /// Model type
  ModelType _modelType = ModelType.UNKNOWN;

  /// Default confidence threshold
  static const double THRESHOLD = 0.5;

  /// Maximum number of detections to return
  static const int NUM_RESULTS = 10;

  /// Default input size
  static const int DEFAULT_INPUT_SIZE = 300;

  /// Model input shapes
  List<List<int>>? _inputShapes;

  /// Model input types
  List<TensorType>? _inputTypes;

  /// Shapes of output tensors
  List<List<int>>? _outputShapes;

  /// Types of output tensors
  List<TensorType>? _outputTypes;

  @override
  dynamic get interpreter => _interpreter;

  @override
  List<String>? get labels => _labels;

  /// Public getters to access model information
  @override
  ModelType get modelType => _modelType;

  @override
  List<List<int>>? get outputShapes => _outputShapes;

  @override
  List<int>? get inputTypes => _inputTypes?.map((t) => t.index).toList();

  @override
  List<int>? get outputTypes => _outputTypes?.map((t) => t.index).toList();

  /// Get input shape from interpreter
  @override
  List<int>? get inputShape {
    if (_inputShapes != null && _inputShapes!.isNotEmpty) {
      return _inputShapes![0];
    }
    return null;
  }

  /// Constructor
  Classifier({
    dynamic interpreter,
    ModelType? modelType,
    List<int>? outputTypes,
    List<List<int>>? outputShapes,
    List<String>? labels,
  }) {
    _interpreter = interpreter;
    _labels = labels;

    if (interpreter != null) {
      _extractModelInfo();
    }

    if (modelType != null) {
      _modelType = modelType;
    }
    if (outputTypes != null) {
      _outputTypes = outputTypes.map((t) => TensorType.values[t]).toList();
    }
    if (outputShapes != null) {
      _outputShapes = outputShapes;
    }
  }

  @override
  Future<void> loadModel({String? modelPath}) async {
    try {
      if (_interpreter != null) {
        _extractModelInfo();
        return;
      }

      // Method 1: Try loading from file path first
      File? modelFile;

      try {
        // Try to copy from assets to a temporary file
        final byteData =
            await rootBundle.load(modelPath ?? 'assets/model.tflite');

        final tempDir = await getTemporaryDirectory();
        final fileName = modelPath?.split('/').last ?? 'model.tflite';
        modelFile = File('${tempDir.path}/$fileName');

        await modelFile.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
        );

        developer.log("Model file created at: ${modelFile.path}");
        developer.log("Model file size: ${modelFile.lengthSync()} bytes");
      } catch (e) {
        developer.log("Error loading model from assets: $e");
        throw Exception("Could not load model file from assets: $e");
      }

      // Create interpreter options
      final options = InterpreterOptions()
        ..threads = 4
        ..useNnApiForAndroid = true
        ..addDelegate(GpuDelegateV2()); // Try GPU delegate if available

      try {
        // Try to create interpreter from file
        _interpreter = await Interpreter.fromFile(
          modelFile,
          options: options,
        );
        developer.log("Interpreter created successfully");
      } catch (e) {
        developer.log("Failed with GPU delegate, trying without: $e");

        // Try without GPU delegate
        final basicOptions = InterpreterOptions()
          ..threads = 4
          ..useNnApiForAndroid = true;

        try {
          _interpreter = await Interpreter.fromFile(
            modelFile,
            options: basicOptions,
          );
          developer.log("Interpreter created successfully (without GPU)");
        } catch (e2) {
          developer.log("Failed with basic options, trying minimal: $e2");

          // Try with minimal options
          try {
            _interpreter = await Interpreter.fromFile(modelFile);
            developer.log("Interpreter created successfully (minimal options)");
          } catch (e3) {
            developer.log("Failed to create interpreter: $e3");

            // Try loading from buffer as last resort
            try {
              final modelBuffer =
                  await rootBundle.load(modelPath ?? 'assets/model.tflite');
              _interpreter = await Interpreter.fromBuffer(
                  modelBuffer.buffer.asUint8List());
              developer.log("Interpreter created from buffer");
            } catch (e4) {
              throw Exception(
                  "Unable to create interpreter with any method: $e4");
            }
          }
        }
      }

      // Extract model information
      _extractModelInfo();
      developer.log("Model loaded successfully ${_interpreter != null}");
    } catch (e) {
      developer.log("Error loading model: $e");
      rethrow;
    }
  }

  @override
  Future<void> loadLabels({String? labelsPath}) async {
    try {
      final labelData =
          await rootBundle.loadString(labelsPath ?? 'assets/labels.txt');
      _labels = labelData
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      developer
          .log("Labels loaded successfully: ${_labels?.length ?? 0} labels");
    } catch (e) {
      developer.log("Error loading labels: $e");
      rethrow;
    }
  }

  /// Get detailed model information as a map (useful for debugging/testing)
  Map<String, dynamic> getModelInfo() {
    return {
      'modelType': _modelType.toString(),
      'modelTypeEnum': _modelType,
      'inputShape': inputShape,
      'outputShapes': _outputShapes,
      'inputTypes': inputTypes,
      'outputTypes': outputTypes,
      'isLoaded': _interpreter != null,
      'labelsCount': _labels?.length ?? 0,
      'threshold': THRESHOLD,
      'inputSize': _getInputSize(),
      'maxResults': NUM_RESULTS,
    };
  }

  /// Get the input size based on model info
  int _getInputSize() {
    if (_inputShapes != null && _inputShapes!.isNotEmpty) {
      final shape = _inputShapes![0];
      if (shape.length >= 3) {
        return shape[1]; // Assuming square input
      }
    }
    return DEFAULT_INPUT_SIZE;
  }

  /// Extract model information
  void _extractModelInfo() {
    if (_interpreter == null) return;

    try {
      var inputTensors = _interpreter!.getInputTensors();
      var outputTensors = _interpreter!.getOutputTensors();

      // Initialize shape and type arrays
      _inputShapes = [];
      _inputTypes = [];
      _outputShapes = [];
      _outputTypes = [];

      // Collect input tensor information
      for (var tensor in inputTensors) {
        _inputShapes!.add(tensor.shape);
        _inputTypes!.add(tensor.type);
      }

      // Collect output tensor information
      for (var tensor in outputTensors) {
        _outputShapes!.add(tensor.shape);
        _outputTypes!.add(tensor.type);
      }

      _determineModelType();

      developer.log("Model information extracted:");
      developer.log("Input tensors: ${inputTensors.length}");
      developer.log("Input shapes: $_inputShapes");
      developer.log("Input types: $_inputTypes");
      developer.log("Output tensors: ${outputTensors.length}");
      developer.log("Output shapes: $_outputShapes");
      developer.log("Output types: $_outputTypes");
      developer.log("Determined model type: $_modelType");
    } catch (e) {
      developer.log("Error extracting model info: $e");
    }
  }

  /// Determine the model type based on tensor shapes
  void _determineModelType() {
    if (_outputShapes == null || _outputShapes!.isEmpty) {
      _modelType = ModelType.UNKNOWN;
      developer.log("Model type set to UNKNOWN: no output shapes");
      return;
    }

    developer.log("Analyzing output shapes: $_outputShapes");
    developer.log("Number of outputs: ${_outputShapes!.length}");

    // Check for YOLOv5 model (4 outputs with specific shapes)
    if (_outputShapes!.length == 4 &&
        _outputShapes![0].length == 2 &&
        _outputShapes![1].length == 3 &&
        _outputShapes![2].length == 1 &&
        _outputShapes![3].length == 2) {
      _modelType = ModelType.YOLOV5;
      developer.log("Model identified as YOLOV5");
      return;
    }

    // Check for PoseNet or similar pose estimation models
    if (_outputShapes!.length == 4 &&
        _outputShapes![0].length == 4 &&
        _outputShapes![0][3] == 17 &&
        _outputShapes![1].length == 4 &&
        _outputShapes![2].length == 4 &&
        _outputShapes![3].length == 4) {
      _modelType = ModelType.POSE_ESTIMATION;
      developer.log(
          "Model identified as POSE_ESTIMATION (multi-output keypoint model)");
      return;
    }

    // Check for MoveNet or lightweight pose model with a single [1, height, width, 17] output
    if (_outputShapes!.length == 1 &&
        _outputShapes![0].length == 4 &&
        _outputShapes![0][3] == 17) {
      _modelType = ModelType.POSE_ESTIMATION;
      developer.log(
          "Model identified as POSE_ESTIMATION (single-output 17 keypoints)");
      return;
    }

    // Check for face detection models (e.g., BlazeFace)
    if (_outputShapes!.length == 2 &&
        _outputShapes![0].length == 3 &&
        _outputShapes![1].length == 3) {
      _modelType = ModelType.FACE_DETECTION;
      developer.log("Model identified as FACE_DETECTION");
      return;
    }

    // Check for segmentation model
    if (_outputShapes!.length == 1 &&
        _outputShapes![0].length == 4 &&
        _outputShapes![0][0] == 1) {
      _modelType = ModelType.SEGMENTATION;
      developer.log("Model identified as SEGMENTATION");
      return;
    }

    // Check for classification model
    if (_outputShapes!.length == 1 &&
        _outputShapes![0].length == 2 &&
        _outputShapes![0][0] == 1) {
      _modelType = ModelType.CLASSIFICATION;
      developer.log("Model identified as CLASSIFICATION");
      return;
    }

    // Generic object detection fallback
    if (_outputShapes!.length == 4) {
      _modelType = ModelType.OBJECT_DETECTION;
      developer
          .log("Model identified as OBJECT_DETECTION (4 outputs detected)");
      return;
    }

    // Fallback if all else fails
    _modelType = ModelType.CLASSIFICATION;
    developer.log("Model identified as CLASSIFICATION (fallback)");
  }

  @override
  Uint8List preprocessImage(imageLib.Image image) {
    // Default values if shapes aren't available
    int inputHeight = DEFAULT_INPUT_SIZE;
    int inputWidth = DEFAULT_INPUT_SIZE;
    int inputChannels = 3;
    TensorType inputType = TensorType.float32;

    // Try to get input dimensions from model info if available
    if (_inputShapes != null && _inputShapes!.isNotEmpty) {
      final inputShape = _inputShapes![0];
      if (inputShape.length >= 3) {
        inputHeight = inputShape[1];
        inputWidth = inputShape[2];
        if (inputShape.length >= 4) {
          inputChannels = inputShape[3];
        }
      }
    }

    // Get input type if available
    if (_inputTypes != null && _inputTypes!.isNotEmpty) {
      inputType = _inputTypes![0];
    }

    developer.log(
        "Processing image to size: ${inputWidth}x${inputHeight}, input type: $inputType");

    // Resize image if needed
    final processedImage =
        (image.width != inputWidth || image.height != inputHeight)
            ? imageLib.copyResize(image, width: inputWidth, height: inputHeight)
            : image;

    // Handle differently based on input type
    if (inputType == TensorType.uint8) {
      developer.log("Using uint8 input format");
      // For uint8 input, create a byte buffer directly
      final byteData = Uint8List(1 * inputHeight * inputWidth * inputChannels);
      int pixelIndex = 0;

      for (int y = 0; y < inputHeight; y++) {
        for (int x = 0; x < inputWidth; x++) {
          final pixel = processedImage.getPixel(x, y);

          // Extract RGB values directly as bytes
          byteData[pixelIndex * inputChannels] = pixel.r.toInt();
          byteData[pixelIndex * inputChannels + 1] = pixel.g.toInt();
          byteData[pixelIndex * inputChannels + 2] = pixel.b.toInt();

          pixelIndex++;
        }
      }

      return byteData;
    } else {
      developer.log("Using float32 input format");
      // For float32 input, use normalization
      final bool normalizeToNegativeOne = true; // Default for float32

      // Create buffer
      final int bufferSize = 1 * inputHeight * inputWidth * inputChannels;
      final Float32List buffer = Float32List(bufferSize);
      int pixelIndex = 0;

      // Process each pixel
      for (int y = 0; y < inputHeight; y++) {
        for (int x = 0; x < inputWidth; x++) {
          final pixel = processedImage.getPixel(x, y);

          // Extract RGB values
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();

          if (normalizeToNegativeOne) {
            // Normalize [0, 255] to [-1, 1]
            buffer[pixelIndex * inputChannels] = (r / 127.5) - 1.0;
            buffer[pixelIndex * inputChannels + 1] = (g / 127.5) - 1.0;
            buffer[pixelIndex * inputChannels + 2] = (b / 127.5) - 1.0;
          }
          pixelIndex++;
        }
      }

      return buffer.buffer.asUint8List();
    }
  }

  @override
  Map<String, dynamic> predict(imageLib.Image image) {
    final predictStartTime = DateTime.now().millisecondsSinceEpoch;

    if (_interpreter == null) {
      developer.log("Interpreter not initialized");
      return {"recognitions": <Recognition>[], "stats": null};
    }

    // Make sure model info is extracted
    if (_inputShapes == null || _outputShapes == null) {
      _extractModelInfo();
    }

    // Preprocess image
    final preProcessStart = DateTime.now().millisecondsSinceEpoch;
    final inputBuffer = preprocessImage(image);
    final preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    // Run inference
    final inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;
    List<Recognition> results = [];

    try {
      if (_modelType == ModelType.OBJECT_DETECTION) {
        developer.log("Running object detection inference");
        results = runObjectDetection(inputBuffer, image);
      } else if (_modelType == ModelType.CLASSIFICATION) {
        developer.log("Running classification inference");
        results = runClassification(inputBuffer, image);
      } else if (_modelType == ModelType.YOLOV5) {
        developer.log("Running YOLOv5 inference");
        results = runYolov5Detection(inputBuffer, image);
      } else if (_modelType == ModelType.FACE_DETECTION) {
        developer.log("Running face detection inference");
        results = runFaceDetection(inputBuffer, image);
      } else if (_modelType == ModelType.POSE_ESTIMATION) {
        developer.log("Running pose estimation inference");
        results = runPoseEstimation(inputBuffer, image);
      } else if (_modelType == ModelType.SEGMENTATION) {
        developer.log("Running segmentation inference");
        results = runSegmentation(inputBuffer, image);
      } else {
        developer.log("Model type unknown, attempting YOLOv5 detection");
        results = runYolov5Detection(inputBuffer, image);
      }
    } catch (e) {
      developer.log("Error during inference: $e");
    }

    final inferenceTimeElapsed =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;
    final predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;

    return {
      "recognitions": results,
      "stats": Stats(
        totalPredictTime: predictElapsedTime,
        inferenceTime: inferenceTimeElapsed,
        preProcessingTime: preProcessElapsedTime,
      )
    };
  }

  @override
  List<Recognition> runObjectDetection(
      Uint8List inputBuffer, imageLib.Image image) {
    try {
      // Create output tensors
      final outputLocations = List<List<List<double>>>.filled(
        1,
        List<List<double>>.filled(
          NUM_RESULTS,
          List<double>.filled(4, 0.0),
        ),
      );

      final outputClasses = List<List<double>>.filled(
        1,
        List<double>.filled(NUM_RESULTS, 0.0),
      );

      final outputScores = List<List<double>>.filled(
        1,
        List<double>.filled(NUM_RESULTS, 0.0),
      );

      final numDetections = List<double>.filled(1, 0.0);

      // Prepare output map
      final outputs = {
        0: outputLocations,
        1: outputClasses,
        2: outputScores,
        3: numDetections,
      };

      // Log input buffer size for debugging
      developer.log("Input buffer size: ${inputBuffer.length}");

      // Check if input type is uint8 or float32
      if (_inputTypes != null &&
          _inputTypes!.isNotEmpty &&
          _inputTypes![0] == TensorType.uint8) {
        developer.log("Running with direct input buffer (uint8)");
        _interpreter!.runForMultipleInputs([inputBuffer], outputs);
      } else {
        developer.log("Running with wrapped input buffer (float32)");
        final inputs = [inputBuffer];
        _interpreter!.runForMultipleInputs(inputs, outputs);
      }

      // Process results
      final List<Recognition> results = [];
      final int numDetected = numDetections[0].toInt();

      developer.log("Number of detections: $numDetected");

      for (int i = 0; i < numDetected; i++) {
        final score = outputScores[0][i];

        if (score > THRESHOLD) {
          final classId = outputClasses[0][i].toInt();
          final label =
              classId < _labels!.length ? _labels![classId] : "Unknown";

          // Get bounding box coordinates
          final top = outputLocations[0][i][0];
          final left = outputLocations[0][i][1];
          final bottom = outputLocations[0][i][2];
          final right = outputLocations[0][i][3];

          // Convert to pixel coordinates
          final boundingBox = Rect.fromLTRB(
            left * image.width,
            top * image.height,
            right * image.width,
            bottom * image.height,
          );

          results.add(Recognition(
            id: i,
            label: label,
            score: score,
            location: boundingBox,
          ));

          developer
              .log("Detection: $label, score: $score, bounds: $boundingBox");
        }
      }

      return results;
    } catch (e, stack) {
      developer.log("Object detection inference error: $e");
      developer.log("Stack trace: $stack");
      return [];
    }
  }

  @override
  List<Recognition> runClassification(
      Uint8List inputBuffer, imageLib.Image image) {
    try {
      // Default number of classes
      int numClasses = _labels?.length ?? 29;

      // Try to determine number of classes from output shape
      if (_outputShapes != null &&
          _outputShapes!.isNotEmpty &&
          _outputShapes![0].length >= 2) {
        numClasses = _outputShapes![0][1];
      }

      // Create output buffer
      final outputBuffer = Float32List(numClasses).buffer.asUint8List();

      // Run inference
      _interpreter!.run(inputBuffer, outputBuffer);

      // Convert back to float32 for processing results
      final outputScores = outputBuffer.buffer.asFloat32List();

      // Log some scores for debugging
      developer.log(
          "Classification scores sample: ${outputScores.sublist(0, math.min(10, outputScores.length))}");

      // Find class with highest score
      int bestClassIndex = 0;
      double bestScore = outputScores[0];

      for (int i = 1; i < outputScores.length; i++) {
        if (outputScores[i] > bestScore) {
          bestScore = outputScores[i];
          bestClassIndex = i;
        }
      }

      // Create results
      final List<Recognition> results = [];

      if (bestScore > THRESHOLD) {
        String label = "Unknown";
        if (_labels != null && bestClassIndex < _labels!.length) {
          label = _labels![bestClassIndex];
        }

        developer.log(
            "Best prediction: Label: $label, Index: $bestClassIndex, Score: $bestScore");

        // Use the entire image as detection area
        final boundingBox = Rect.fromLTRB(
          0,
          0,
          image.width.toDouble(),
          image.height.toDouble(),
        );

        results.add(Recognition(
          id: bestClassIndex,
          label: label,
          score: bestScore,
          location: boundingBox,
        ));
      } else {
        developer.log(
            "No prediction above threshold. Best score: $bestScore at index $bestClassIndex");
      }

      return results;
    } catch (e, stack) {
      developer.log("Classification inference error: $e");
      developer.log("Stack trace: $stack");
      return [];
    }
  }

  @override
  List<Recognition> runYolov5Detection(
      Uint8List inputBuffer, imageLib.Image image) {
    try {
      // Create output tensors based on the shapes provided
      final outputClasses = List<List<double>>.filled(
        1,
        List<double>.filled(10, 0.0),
      );

      final outputLocations = List<List<List<double>>>.filled(
        1,
        List<List<double>>.filled(
          10,
          List<double>.filled(4, 0.0),
        ),
      );

      final outputMeta = List<double>.filled(1, 0.0);

      final outputScores = List<List<double>>.filled(
        1,
        List<double>.filled(10, 0.0),
      );

      // Prepare output map based on the YOLOv5 output format
      final outputs = {
        0: outputClasses, // [1, 10]
        1: outputLocations, // [1, 10, 4]
        2: outputMeta, // [1]
        3: outputScores, // [1, 10]
      };

      // Log input buffer size for debugging
      developer.log("Input buffer size: ${inputBuffer.length}");

      // Run inference
      if (_inputTypes != null &&
          _inputTypes!.isNotEmpty &&
          _inputTypes![0] == TensorType.uint8) {
        developer.log("Running with direct input buffer (uint8)");
        _interpreter!.runForMultipleInputs([inputBuffer], outputs);
      } else {
        developer.log("Running with wrapped input buffer (float32)");
        final inputs = [inputBuffer];
        _interpreter!.runForMultipleInputs(inputs, outputs);
      }

      // Process results
      final List<Recognition> results = [];

      // For YOLOv5, process all 10 potential detections
      for (int i = 0; i < 10; i++) {
        final score = outputScores[0][i];

        if (score > THRESHOLD) {
          final classId = outputClasses[0][i].toInt();

          String label = "Unknown";
          if (_labels != null && classId < _labels!.length) {
            label = _labels![classId];
          }

          // YOLOv5 typically outputs coordinates as [x1, y1, x2, y2]
          final x1 = outputLocations[0][i][0];
          final y1 = outputLocations[0][i][1];
          final x2 = outputLocations[0][i][2];
          final y2 = outputLocations[0][i][3];

          // Create bounding box based on coordinates
          final boundingBox = Rect.fromLTRB(
            x1 * image.width,
            y1 * image.height,
            x2 * image.width,
            y2 * image.height,
          );

          results.add(Recognition(
            id: i,
            label: label,
            score: score,
            location: boundingBox,
          ));

          developer.log(
              "YOLOv5 Detection: $label, score: $score, bounds: $boundingBox");
        }
      }

      return results;
    } catch (e, stack) {
      developer.log("YOLOv5 inference error: $e");
      developer.log("Stack trace: $stack");
      return [];
    }
  }

  @override
  List<Recognition> runFaceDetection(
      Uint8List inputBuffer, imageLib.Image image) {
    try {
      final outputFaceBoxes = List<List<List<double>>>.filled(
        1,
        List<List<double>>.filled(
          10, // max 10 faces
          List<double>.filled(4, 0.0), // x1, y1, x2, y2
        ),
      );

      final outputFaceLandmarks = List<List<List<double>>>.filled(
        1,
        List<List<double>>.filled(
          10, // max 10 faces
          List<double>.filled(10, 0.0), // 5 landmarks x 2 coordinates
        ),
      );

      final outputs = {
        0: outputFaceBoxes,
        1: outputFaceLandmarks,
      };

      _interpreter!.runForMultipleInputs([inputBuffer], outputs);

      final List<Recognition> results = [];

      for (int i = 0; i < 10; i++) {
        final box = outputFaceBoxes[0][i];

        if (box[0] != 0.0 || box[1] != 0.0 || box[2] != 0.0 || box[3] != 0.0) {
          final confidence = (box[2] - box[0]) * (box[3] - box[1]);

          if (confidence > THRESHOLD) {
            final boundingBox = Rect.fromLTRB(
              box[0] * image.width,
              box[1] * image.height,
              box[2] * image.width,
              box[3] * image.height,
            );

            final landmarks = outputFaceLandmarks[0][i];
            final landmarkPoints = <Offset>[];
            for (int j = 0; j < 10; j += 2) {
              landmarkPoints.add(Offset(
                landmarks[j] * image.width,
                landmarks[j + 1] * image.height,
              ));
            }

            // Use the factory constructor
            results.add(Recognition.faceDetection(
              id: i,
              score: confidence.clamp(0.0, 1.0),
              location: boundingBox,
              landmarks: landmarkPoints,
            ));
          }
        }
      }

      return results;
    } catch (e, stack) {
      developer.log("Face detection inference error: $e");
      developer.log("Stack trace: $stack");
      return [];
    }
  }

  @override
  List<Recognition> runPoseEstimation(
      Uint8List inputBuffer, imageLib.Image image) {
    try {
      final outputKeypoints = List<List<List<double>>>.filled(
        1,
        List<List<double>>.filled(
          17, // 17 COCO keypoints
          List<double>.filled(3, 0.0), // x, y, confidence
        ),
      );

      final outputs = {
        0: outputKeypoints,
      };

      _interpreter!.runForMultipleInputs([inputBuffer], outputs);

      final List<Recognition> results = [];
      final keypoints = outputKeypoints[0];

      final validKeypoints =
          keypoints.where((kp) => kp[2] > THRESHOLD).toList();

      if (validKeypoints.length >= 5) {
        final totalConfidence =
            validKeypoints.fold(0.0, (sum, kp) => sum + kp[2]);
        final avgConfidence = totalConfidence / validKeypoints.length;

        final validX = validKeypoints.map((kp) => kp[0]).where((x) => x > 0);
        final validY = validKeypoints.map((kp) => kp[1]).where((y) => y > 0);

        if (validX.isNotEmpty && validY.isNotEmpty) {
          final minX = validX.reduce((a, b) => a < b ? a : b);
          final maxX = validX.reduce((a, b) => a > b ? a : b);
          final minY = validY.reduce((a, b) => a < b ? a : b);
          final maxY = validY.reduce((a, b) => a > b ? a : b);

          final boundingBox = Rect.fromLTRB(
            minX * image.width,
            minY * image.height,
            maxX * image.width,
            maxY * image.height,
          );

          final keypointOffsets = <Offset>[];
          for (final kp in keypoints) {
            keypointOffsets.add(Offset(
              kp[0] * image.width,
              kp[1] * image.height,
            ));
          }

          // Use the factory constructor
          results.add(Recognition.poseEstimation(
            id: 0,
            score: avgConfidence,
            location: boundingBox,
            keypoints: keypointOffsets,
          ));
        }
      }

      return results;
    } catch (e, stack) {
      developer.log("Pose estimation inference error: $e");
      developer.log("Stack trace: $stack");
      return [];
    }
  }

  @override
  List<Recognition> runSegmentation(
      Uint8List inputBuffer, imageLib.Image image) {
    try {
      final outputHeight = 256;
      final outputWidth = 256;
      final numClasses = _labels?.length ?? 21;

      final outputSegmentation = List<List<List<List<double>>>>.filled(
        1,
        List<List<List<double>>>.filled(
          outputHeight,
          List<List<double>>.filled(
            outputWidth,
            List<double>.filled(numClasses, 0.0),
          ),
        ),
      );

      final outputs = {
        0: outputSegmentation,
      };

      _interpreter!.runForMultipleInputs([inputBuffer], outputs);

      final List<Recognition> results = [];
      final segMask = outputSegmentation[0];

      final detectedClasses = <int, double>{};
      final classBoundingBoxes = <int, List<Offset>>{};

      for (int y = 0; y < outputHeight; y++) {
        for (int x = 0; x < outputWidth; x++) {
          final classProbs = segMask[y][x];

          double maxProb = 0.0;
          int maxClassId = 0;

          for (int c = 0; c < numClasses; c++) {
            if (classProbs[c] > maxProb) {
              maxProb = classProbs[c];
              maxClassId = c;
            }
          }

          if (maxProb > THRESHOLD && maxClassId > 0) {
            detectedClasses[maxClassId] = math.max(
              detectedClasses[maxClassId] ?? 0.0,
              maxProb,
            );

            classBoundingBoxes[maxClassId] ??= <Offset>[];
            classBoundingBoxes[maxClassId]!.add(Offset(
              x.toDouble(),
              y.toDouble(),
            ));
          }
        }
      }

      int recognitionId = 0;
      detectedClasses.forEach((classId, confidence) {
        final pixelLocations = classBoundingBoxes[classId] ?? [];

        if (pixelLocations.isNotEmpty) {
          final xCoords = pixelLocations.map((p) => p.dx);
          final yCoords = pixelLocations.map((p) => p.dy);

          final minX = xCoords.reduce((a, b) => a < b ? a : b);
          final maxX = xCoords.reduce((a, b) => a > b ? a : b);
          final minY = yCoords.reduce((a, b) => a < b ? a : b);
          final maxY = yCoords.reduce((a, b) => a > b ? a : b);

          final boundingBox = Rect.fromLTRB(
            (minX / outputWidth) * image.width,
            (minY / outputHeight) * image.height,
            (maxX / outputWidth) * image.width,
            (maxY / outputHeight) * image.height,
          );

          final label =
              classId < _labels!.length ? _labels![classId] : "Unknown";

          // Use the factory constructor
          results.add(Recognition.segmentation(
            id: recognitionId++,
            label: label,
            score: confidence,
            location: boundingBox,
            segmentationMask: pixelLocations,
          ));
        }
      });

      return results;
    } catch (e, stack) {
      developer.log("Segmentation inference error: $e");
      developer.log("Stack trace: $stack");
      return [];
    }
  }

  @override
  void close() {
    _interpreter?.close();
  }
}
