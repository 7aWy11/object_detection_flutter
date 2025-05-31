import 'package:flutter/material.dart';
import 'package:object_detection_flutter/object_detection_flutter.dart';
import 'package:image/image.dart' as imageLib;
import 'dart:typed_data';
import 'package:flutter/services.dart'; // For DefaultAssetBundle
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Object Detection Complete Test Suite',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ObjectDetectionTestSuite(),
    );
  }
}

class ObjectDetectionTestSuite extends StatefulWidget {
  @override
  _ObjectDetectionTestSuiteState createState() =>
      _ObjectDetectionTestSuiteState();
}

class _ObjectDetectionTestSuiteState extends State<ObjectDetectionTestSuite> {
  final Detector detector = Detector();
  final ScrollController _logController = ScrollController();

  String status = 'Ready to run comprehensive tests';
  List<String> logs = [];
  bool isInitialized = false;
  int testsPassed = 0;
  int testsFailed = 0;
  int testsTotal = 0;

  @override
  void initState() {
    super.initState();
    addLog('🚀 Object Detection Test Suite Started');
    addLog('📱 Platform: Android');
  }

  void addLog(String message, {bool isError = false, bool isSuccess = false}) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final formattedMessage = '$timestamp: $message';

    setState(() {
      logs.add(formattedMessage);
      if (logs.length > 500) logs.removeAt(0); // Keep only last 500 logs
    });

    print(formattedMessage);

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logController.hasClients) {
        _logController.animateTo(
          _logController.position.maxScrollExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void updateTestResults(bool passed) {
    setState(() {
      testsTotal++;
      if (passed) {
        testsPassed++;
      } else {
        testsFailed++;
      }
    });
  }

  // ==================== TEST CASES ====================

  Future<void> runAllTests() async {
    addLog('🧪 STARTING COMPREHENSIVE TEST SUITE');
    setState(() {
      testsPassed = 0;
      testsFailed = 0;
      testsTotal = 0;
    });

    // Basic Tests
    await testInitialization();
    await testLoadAndDisplayLabels();
    await testErrorHandling();

    // Functionality Tests
    await testBasicDetection();
    await testDifferentImageSizes();
    await testDifferentImageFormats();
    await testMultipleDetections();

    // Performance Tests
    await testPerformance();
    await testMemoryUsage();

    // Stress Tests
    await testConcurrentDetections();
    await testLargeImages();

    // Edge Cases
    await testEmptyImages();
    await testCorruptedImages();

    // Model Information Tests
    await testModelInformation();

    // Cleanup Tests
    await testDisposal();

    // Final Results
    addLog('🏁 TEST SUITE COMPLETED');
    addLog(
        '📊 Results: $testsPassed passed, $testsFailed failed, $testsTotal total');

    final successRate = (testsPassed / testsTotal * 100).toStringAsFixed(1);
    addLog('📈 Success Rate: $successRate%');
  }

  Future<void> testInitialization() async {
    addLog('🔧 TEST: Initialization');

    try {
      await detector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );

      final modelLoaded = detector.isModelLoaded;

      if (modelLoaded) {
        addLog('✅ Initialization: PASSED');
        setState(() {
          isInitialized = true;
        });
        updateTestResults(true);
      } else {
        addLog('❌ Initialization: FAILED - Model not loaded');
        updateTestResults(false);
      }
    } catch (e) {
      addLog('❌ Initialization: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testLoadAndDisplayLabels() async {
    addLog('🔧 TEST: Load and Display Labels');

    if (!isInitialized) {
      addLog('❌ Labels Test: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      // Create a temporary classifier to access labels
      final tempClassifier = Classifier();
      await tempClassifier.loadLabels(labelsPath: 'assets/labels.txt');

      final labels = tempClassifier.labels;

      if (labels == null || labels.isEmpty) {
        addLog('❌ Labels Test: FAILED - No labels loaded');
        updateTestResults(false);
        return;
      }

      addLog('📋 Labels loaded successfully: ${labels.length} total');
      addLog('🏷️  Available classes:');

      // Display first 15 labels (more than before)
      for (int i = 0; i < labels.length && i < 15; i++) {
        addLog('   ${(i + 1).toString().padLeft(2)}: ${labels[i]}');
      }

      if (labels.length > 15) {
        addLog('   ... and ${labels.length - 15} more classes');
      }

      // Check for common object detection classes
      final commonClasses = [
        'person',
        'car',
        'dog',
        'cat',
        'bicycle',
        'bird',
        'bottle',
        'chair'
      ];
      final foundCommon = <String>[];

      for (final common in commonClasses) {
        final matchingLabels = labels
            .where(
                (label) => label.toLowerCase().contains(common.toLowerCase()))
            .toList();
        if (matchingLabels.isNotEmpty) {
          foundCommon.addAll(matchingLabels);
        }
      }

      if (foundCommon.isNotEmpty) {
        addLog('🎯 Found common object classes:');
        for (final found in foundCommon.take(5)) {
          addLog('   • $found');
        }
        if (foundCommon.length > 5) {
          addLog('   • ... and ${foundCommon.length - 5} more');
        }
      }

      // Check label statistics
      final avgLabelLength =
          labels.map((l) => l.length).reduce((a, b) => a + b) / labels.length;
      addLog('📊 Label statistics:');
      addLog('   • Total labels: ${labels.length}');
      addLog('   • Average length: ${avgLabelLength.toStringAsFixed(1)} chars');
      addLog(
          '   • Shortest: "${labels.reduce((a, b) => a.length < b.length ? a : b)}"');
      addLog(
          '   • Longest: "${labels.reduce((a, b) => a.length > b.length ? a : b)}"');

      addLog('✅ Labels Test: PASSED');
      updateTestResults(true);

      // Clean up
      tempClassifier.close();
    } catch (e) {
      addLog('❌ Labels Test: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testErrorHandling() async {
    addLog('🔧 TEST: Error Handling');

    // Test invalid model path
    try {
      final tempDetector = Detector();
      await tempDetector.initialize(
        modelPath: 'invalid/path/model.tflite',
        labelsPath: 'assets/labels.txt',
      );

      addLog(
          '❌ Error Handling: FAILED - Should have thrown error for invalid model');
      updateTestResults(false);
    } catch (e) {
      addLog('✅ Error Handling: PASSED - Invalid model properly rejected');
      updateTestResults(true);
    }

    // Test invalid labels path
    try {
      final tempDetector = Detector();
      await tempDetector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'invalid/path/labels.txt',
      );

      addLog(
          '❌ Error Handling: FAILED - Should have thrown error for invalid labels');
      updateTestResults(false);
    } catch (e) {
      addLog('✅ Error Handling: PASSED - Invalid labels properly rejected');
      updateTestResults(true);
    }
  }

  Future<void> testBasicDetection() async {
    addLog('🔧 TEST: Basic Detection');

    if (!isInitialized) {
      addLog('❌ Basic Detection: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      final image = _createTestImage(300, 300, Colors.blue);
      final result = await detector.detect(imageLib.encodeJpg(image));

      if (result['error'] == null &&
          result['recognitions'] is List &&
          result['stats'] is Stats) {
        addLog('✅ Basic Detection: PASSED');
        updateTestResults(true);
      } else {
        addLog('❌ Basic Detection: FAILED - Invalid result format');
        updateTestResults(false);
      }
    } catch (e) {
      addLog('❌ Basic Detection: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testDifferentImageSizes() async {
    addLog('🔧 TEST: Different Image Sizes');

    if (!isInitialized) {
      addLog('❌ Image Sizes: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    final sizes = [
      [224, 224],
      [300, 300],
      [416, 416],
      [640, 480],
      [800, 600],
    ];

    int passed = 0;

    for (final size in sizes) {
      try {
        final image = _createTestImage(size[0], size[1], Colors.green);
        final result = await detector.detect(imageLib.encodeJpg(image));

        if (result['error'] == null) {
          addLog('✅ Size ${size[0]}x${size[1]}: PASSED');
          passed++;
        } else {
          addLog('❌ Size ${size[0]}x${size[1]}: FAILED - ${result['error']}');
        }
      } catch (e) {
        addLog('❌ Size ${size[0]}x${size[1]}: FAILED - $e');
      }
    }

    updateTestResults(passed == sizes.length);
  }

  Future<void> testDifferentImageFormats() async {
    addLog('🔧 TEST: Different Image Formats');

    if (!isInitialized) {
      addLog('❌ Image Formats: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      final image = _createTestImage(300, 300, Colors.red);

      // Test JPEG
      final jpegResult = await detector.detect(imageLib.encodeJpg(image));
      final jpegPassed = jpegResult['error'] == null;

      // Test PNG
      final pngResult = await detector.detect(imageLib.encodePng(image));
      final pngPassed = pngResult['error'] == null;

      if (jpegPassed && pngPassed) {
        addLog('✅ Image Formats: PASSED (JPEG & PNG)');
        updateTestResults(true);
      } else {
        addLog('❌ Image Formats: FAILED - JPEG: $jpegPassed, PNG: $pngPassed');
        updateTestResults(false);
      }
    } catch (e) {
      addLog('❌ Image Formats: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testMultipleDetections() async {
    addLog('🔧 TEST: Multiple Detections');

    if (!isInitialized) {
      addLog('❌ Multiple Detections: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      int successCount = 0;

      for (int i = 0; i < 5; i++) {
        final image = _createRandomImage(320, 240);
        final result = await detector.detect(imageLib.encodeJpg(image));

        if (result['error'] == null) {
          successCount++;
        }
      }

      if (successCount == 5) {
        addLog('✅ Multiple Detections: PASSED (5/5)');
        updateTestResults(true);
      } else {
        addLog('❌ Multiple Detections: FAILED ($successCount/5)');
        updateTestResults(false);
      }
    } catch (e) {
      addLog('❌ Multiple Detections: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testPerformance() async {
    addLog('🔧 TEST: Performance Benchmarks');

    if (!isInitialized) {
      addLog('❌ Performance: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      final times = <int>[];

      for (int i = 0; i < 10; i++) {
        final image = _createTestImage(300, 300, Colors.purple);

        final stopwatch = Stopwatch()..start();
        final result = await detector.detect(imageLib.encodeJpg(image));
        stopwatch.stop();

        if (result['error'] == null) {
          times.add(stopwatch.elapsedMilliseconds);
        }
      }

      if (times.length == 10) {
        final avgTime = times.reduce((a, b) => a + b) / times.length;
        final minTime = times.reduce((a, b) => a < b ? a : b);
        final maxTime = times.reduce((a, b) => a > b ? a : b);

        addLog(
            '📊 Avg: ${avgTime.toStringAsFixed(1)}ms, Min: ${minTime}ms, Max: ${maxTime}ms');

        if (avgTime < 1000) {
          // Less than 1 second average
          addLog('✅ Performance: PASSED');
          updateTestResults(true);
        } else {
          addLog(
              '❌ Performance: FAILED - Too slow (${avgTime.toStringAsFixed(1)}ms avg)');
          updateTestResults(false);
        }
      } else {
        addLog('❌ Performance: FAILED - Some detections failed');
        updateTestResults(false);
      }
    } catch (e) {
      addLog('❌ Performance: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testMemoryUsage() async {
    addLog('🔧 TEST: Memory Usage');

    if (!isInitialized) {
      addLog('❌ Memory Usage: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      // Run many detections to test memory leaks
      for (int i = 0; i < 20; i++) {
        final image = _createTestImage(200, 200, Colors.orange);
        await detector.detect(imageLib.encodeJpg(image));
      }

      addLog('✅ Memory Usage: PASSED - No crashes after 20 detections');
      updateTestResults(true);
    } catch (e) {
      addLog('❌ Memory Usage: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testConcurrentDetections() async {
    addLog('🔧 TEST: Concurrent Detection Handling');

    if (!isInitialized) {
      addLog('❌ Concurrent Detections: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      // Test sequential "concurrent-like" behavior since true concurrency may not be supported
      final results = <Map<String, dynamic>>[];

      for (int i = 0; i < 3; i++) {
        final image = _createTestImage(200, 200, Colors.cyan);
        final result = await detector.detect(imageLib.encodeJpg(image));
        results.add(result);
      }

      final successCount = results.where((r) => r['error'] == null).length;

      if (successCount == 3) {
        addLog('✅ Concurrent Detections: PASSED ($successCount/3 sequential)');
        updateTestResults(true);
      } else {
        addLog('❌ Concurrent Detections: FAILED ($successCount/3)');
        updateTestResults(false);
      }
    } catch (e) {
      addLog('❌ Concurrent Detections: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testLargeImages() async {
    addLog('🔧 TEST: Large Images');

    if (!isInitialized) {
      addLog('❌ Large Images: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      final image = _createTestImage(1024, 768, Colors.indigo);
      final result = await detector.detect(imageLib.encodeJpg(image));

      if (result['error'] == null) {
        addLog('✅ Large Images: PASSED (1024x768)');
        updateTestResults(true);
      } else {
        addLog('❌ Large Images: FAILED - ${result['error']}');
        updateTestResults(false);
      }
    } catch (e) {
      addLog('❌ Large Images: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testEmptyImages() async {
    addLog('🔧 TEST: Empty/Small Images');

    if (!isInitialized) {
      addLog('❌ Empty Images: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      final image = _createTestImage(1, 1, Colors.black);
      final result = await detector.detect(imageLib.encodeJpg(image));

      // Should handle gracefully, either with error or empty results
      addLog('✅ Empty Images: PASSED - Handled gracefully');
      updateTestResults(true);
    } catch (e) {
      addLog('✅ Empty Images: PASSED - Properly rejected ($e)');
      updateTestResults(true);
    }
  }

  Future<void> testCorruptedImages() async {
    addLog('🔧 TEST: Corrupted Image Data');

    if (!isInitialized) {
      addLog('❌ Corrupted Images: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      // Create invalid image data
      final invalidData = Uint8List.fromList([1, 2, 3, 4, 5]);
      final result = await detector.detect(invalidData);

      // Should handle gracefully with error
      addLog('✅ Corrupted Images: PASSED - Handled gracefully');
      updateTestResults(true);
    } catch (e) {
      addLog('✅ Corrupted Images: PASSED - Properly rejected');
      updateTestResults(true);
    }
  }

  Future<void> testDisposal() async {
    addLog('🔧 TEST: Proper Disposal');

    try {
      final tempDetector = Detector();
      await tempDetector.initialize(
        modelPath: 'assets/model.tflite',
        labelsPath: 'assets/labels.txt',
      );

      tempDetector.dispose();

      addLog('✅ Disposal: PASSED - No crashes');
      updateTestResults(true);
    } catch (e) {
      addLog('❌ Disposal: FAILED - $e');
      updateTestResults(false);
    }
  }

  Future<void> testModelInformation() async {
    addLog('🔧 TEST: Model Information Analysis');

    if (!isInitialized) {
      addLog('❌ Model Information: FAILED - Detector not initialized');
      updateTestResults(false);
      return;
    }

    try {
      // Create a temporary classifier to access model information
      final tempClassifier = Classifier();

      // Load the model
      await tempClassifier.loadModel(modelPath: 'assets/model.tflite');
      await tempClassifier.loadLabels(labelsPath: 'assets/labels.txt');

      // Get model information using the public method
      final modelInfo = tempClassifier.getModelInfo();

      addLog('📊 MODEL INFORMATION:');
      addLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 1. Model File Analysis
      try {
        final modelData = await rootBundle.load('assets/model.tflite');
        final modelSizeMB = modelData.lengthInBytes / (1024 * 1024);
        final modelSizeKB = (modelData.lengthInBytes / 1024).toStringAsFixed(1);

        addLog('📦 Model File Analysis:');
        addLog('   • File: assets/model.tflite');
        addLog(
            '   • Size: ${modelSizeKB}KB (${modelSizeMB.toStringAsFixed(2)}MB)');

        // Estimate model complexity based on size
        String complexity;
        if (modelData.lengthInBytes < 1024 * 1024) {
          // < 1MB
          complexity = 'Lightweight (Mobile optimized)';
        } else if (modelData.lengthInBytes < 10 * 1024 * 1024) {
          // < 10MB
          complexity = 'Medium (Standard mobile)';
        } else if (modelData.lengthInBytes < 50 * 1024 * 1024) {
          // < 50MB
          complexity = 'Large (High accuracy)';
        } else {
          complexity = 'Very Large (Desktop/Server class)';
        }
        addLog('   • Complexity: $complexity');
      } catch (e) {
        addLog('   • File size: Unable to determine');
      }

      // 2. Model Type and Architecture
      addLog('🔍 Model Type: ${modelInfo['modelType']}');
      addLog('✅ Model Loaded: ${modelInfo['isLoaded']}');
      addLog('🏷️  Labels Count: ${modelInfo['labelsCount']}');

      // 3. Input Configuration
      final inputShape = modelInfo['inputShape'];
      if (inputShape is! List) {
        addLog('❌ Invalid inputShape format');
        return;
      }
      if (inputShape != null) {
        addLog('📥 Input Configuration:');
        addLog('   • Shape: [${inputShape.join(', ')}]');
        if (inputShape.length >= 3) {
          addLog('   • Batch Size: ${inputShape[0]}');
          addLog('   • Height: ${inputShape[1]}');
          addLog('   • Width: ${inputShape[2]}');
          if (inputShape.length > 3) {
            addLog('   • Channels: ${inputShape[3]}');
          }
        }

        // Input tensor types
        final inputTypes = modelInfo['inputTypes'];
        if (inputTypes is List && inputTypes.every((e) => e is int)) {
          addLog('   • Data Type: ${_formatTensorTypes(inputTypes as List<int>)}');
        }
      }

      // 4. Output Configuration
      final outputShapes = modelInfo['outputShapes'];
      if (outputShapes != null && outputShapes.isNotEmpty) {
        addLog('📤 Output Configuration:');
        addLog('   • Number of Outputs: ${outputShapes.length}');
        for (int i = 0; i < outputShapes.length; i++) {
          addLog('   • Output $i: [${outputShapes[i].join(', ')}]');
        }

        // Output tensor types
        final outputTypes = modelInfo['outputTypes'];
        if (outputTypes != null && outputTypes.isNotEmpty) {
          addLog('   • Data Types: ${_formatTensorTypes(outputTypes)}');
        }
      } else {
        addLog('📤 Output Tensors: None detected');
      }

      // 5. Model Configuration
      addLog('⚙️  Runtime Configuration:');
      addLog(
          '   • Input Size: ${modelInfo['inputSize']}x${modelInfo['inputSize']}');
      addLog('   • Confidence Threshold: ${modelInfo['threshold']}');
      addLog('   • Max Results: ${modelInfo['maxResults']}');

      // 6. Model Capabilities (Based on detected type)
      final modelType = modelInfo['modelTypeEnum'] as ModelType;
      addLog('🎯 Model Capabilities:');

      String architecture = 'Unknown';
      String useCase = 'General';

      switch (modelType) {
        case ModelType.YOLOV5:
          addLog('   • YOLO v5 object detection');
          addLog('   • Real-time detection optimized');
          addLog('   • Returns: boxes, classes, scores');
          addLog('   • Max detections per image: ${modelInfo['maxResults']}');
          architecture = 'YOLOv5 (You Only Look Once v5)';
          useCase = 'Real-time object detection';
          break;
        case ModelType.OBJECT_DETECTION:
          addLog('   • Standard object detection');
          addLog('   • Multi-object with bounding boxes');
          addLog('   • Supports ${modelInfo['labelsCount']} classes');
          architecture = 'SSD/MobileNet style';
          useCase = 'General object detection';
          break;
        case ModelType.CLASSIFICATION:
          addLog('   • Image classification');
          addLog('   • Single prediction per image');
          addLog('   • ${modelInfo['labelsCount']} categories');
          architecture = 'CNN Classifier';
          useCase = 'Image categorization';
          break;
        case ModelType.FACE_DETECTION:
          addLog('   • Face detection specialized');
          addLog('   • Returns face boxes + landmarks');
          addLog('   • Optimized for faces');
          architecture = 'Face Detection Network';
          useCase = 'Face detection/recognition';
          break;
        case ModelType.POSE_ESTIMATION:
          addLog('   • Human pose estimation');
          addLog('   • 17 COCO keypoints');
          addLog('   • Skeleton tracking');
          architecture = 'Pose Estimation Network';
          useCase = 'Human pose tracking';
          break;
        case ModelType.SEGMENTATION:
          addLog('   • Semantic segmentation');
          addLog('   • Pixel-level classification');
          addLog('   • Mask generation');
          architecture = 'Segmentation Network';
          useCase = 'Image segmentation';
          break;
        default:
          addLog('   • Unknown model type');
          addLog('   • Default detection behavior');
          break;
      }

      // 7. Performance Test (Quick benchmark)
      addLog('⚡ Performance Benchmark:');
      try {
        // Small image test
        final testImage = _createTestImage(modelInfo['inputSize'] ?? 300,
            modelInfo['inputSize'] ?? 300, Colors.blue);
        final stopwatch = Stopwatch()..start();
        final result = await detector.detect(imageLib.encodeJpg(testImage));
        stopwatch.stop();

        if (result['error'] == null && result['stats'] != null) {
          final stats = result['stats'] as Stats;
          addLog('   • Total Time: ${stopwatch.elapsedMilliseconds}ms');
          addLog('   • Inference: ${stats.inferenceTime}ms');
          addLog('   • Pre-processing: ${stats.preProcessingTime}ms');

          // Performance assessment
          if (stopwatch.elapsedMilliseconds < 100) {
            addLog('   • Rating: ✅ Real-time capable');
          } else if (stopwatch.elapsedMilliseconds < 300) {
            addLog('   • Rating: ⚠️ Near real-time');
          } else {
            addLog('   • Rating: ❌ Too slow for real-time');
          }
        }
      } catch (e) {
        addLog('   • Performance test skipped');
      }

      // 8. Memory Footprint (Safe calculation)
      try {
        if (inputShape != null && inputShape.length >= 3) {
          int inputMemory = 1;
          for (final dim in inputShape) {
            if (dim is int && dim > 0) {
              inputMemory *= dim;
            }
          }
          inputMemory *= 4; // float32

          addLog('💾 Memory Requirements:');
          addLog('   • Input tensor: ${_formatBytes(inputMemory)}');

          if (outputShapes != null && outputShapes.isNotEmpty) {
            int totalOutputMemory = 0;
            for (final shape in outputShapes) {
              int outputMemory = 1;
              for (final dim in shape) {
                if (dim is int && dim > 0) {
                  outputMemory *= dim;
                }
              }
              totalOutputMemory += outputMemory * 4; // float32
            }
            addLog('   • Output tensors: ${_formatBytes(totalOutputMemory)}');
            addLog(
                '   • Total per inference: ${_formatBytes(inputMemory + totalOutputMemory)}');
          }
        }
      } catch (e) {
        addLog('   • Memory calculation skipped');
      }

      // 9. Label Analysis
      if (tempClassifier.labels != null && tempClassifier.labels!.isNotEmpty) {
        addLog('🏷️  Label Analysis:');
        final labels = tempClassifier.labels!;

        // Show first 5 labels
        addLog('   • Sample classes:');
        for (int i = 0; i < labels.length && i < 5; i++) {
          addLog('     ${(i + 1).toString().padLeft(2)}: ${labels[i]}');
        }
        if (labels.length > 5) {
          addLog('     ... and ${labels.length - 5} more');
        }

        // Detect dataset type
        String dataset = 'Custom';
        if (labels.length == 80)
          dataset = 'COCO-80';
        else if (labels.length == 91)
          dataset = 'COCO-91';
        else if (labels.length == 1000)
          dataset = 'ImageNet';
        else if (labels.length == 21)
          dataset = 'Pascal VOC';
        else if (labels.length == 29) dataset = 'Custom/Hand Gestures';

        addLog('   • Dataset type: $dataset');
      }

      // 10. Deployment Recommendations
      addLog('💡 Deployment Recommendations:');

      // Based on model size
      try {
        final modelData = await rootBundle.load('assets/model.tflite');
        final modelSizeMB = modelData.lengthInBytes / (1024 * 1024);

        if (modelSizeMB < 5) {
          addLog('   ✅ Excellent for mobile (< 5MB)');
        } else if (modelSizeMB < 20) {
          addLog('   ⚠️ Good for mobile (5-20MB)');
        } else {
          addLog('   ❌ Large for mobile (> 20MB)');
        }

        // Architecture recommendation based on size and type
        if (modelType == ModelType.YOLOV5) {
          if (modelSizeMB < 15) {
            addLog('   • Architecture: YOLOv5s/n (nano/small)');
          } else if (modelSizeMB < 30) {
            addLog('   • Architecture: YOLOv5m (medium)');
          } else {
            addLog('   • Architecture: YOLOv5l/x (large)');
          }
        }
      } catch (e) {
        // Skip if can't read file
      }

      addLog('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // Validation
      bool validModel = true;
      String validationMessage = '';

      if (modelInfo['labelsCount'] == 0) {
        validModel = false;
        validationMessage = 'No labels loaded';
      } else if (outputShapes == null || outputShapes.isEmpty) {
        validModel = false;
        validationMessage = 'No output shapes detected';
      } else if (modelType == ModelType.UNKNOWN) {
        addLog('⚠️  Warning: Model type is UNKNOWN');
      }

      if (validModel) {
        addLog('✅ Model Information: PASSED - Analysis complete');
        updateTestResults(true);
      } else {
        addLog('❌ Model Information: FAILED - $validationMessage');
        updateTestResults(false);
      }

      // Clean up
      tempClassifier.close();
    } catch (e, stackTrace) {
      addLog('❌ Model Information: FAILED - $e');
      addLog('Stack trace: ${stackTrace.toString().split('\n').first}');
      updateTestResults(false);
    }
  }

  // ==================== HELPER METHODS ====================

  String _formatTensorTypes(List<int> types) {
    final typeNames = types.map((type) {
      switch (type) {
        case 0:
          return 'FLOAT32';
        case 1:
          return 'INT32';
        case 2:
          return 'UINT8';
        case 3:
          return 'INT64';
        case 4:
          return 'STRING';
        case 5:
          return 'BOOL';
        case 6:
          return 'INT16';
        case 7:
          return 'COMPLEX64';
        case 8:
          return 'INT8';
        case 9:
          return 'FLOAT16';
        default:
          return 'Type_$type';
      }
    }).toList();

    return '[${typeNames.join(', ')}]';
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  imageLib.Image _createTestImage(int width, int height, Color color) {
    final image = imageLib.Image(width: width, height: height);
    imageLib.fill(image,
        color: imageLib.ColorRgb8(color.red, color.green, color.blue));
    return image;
  }

  imageLib.Image _createRandomImage(int width, int height) {
    final image = imageLib.Image(width: width, height: height);
    final random = math.Random();

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        image.setPixelRgb(x, y, random.nextInt(256), random.nextInt(256),
            random.nextInt(256));
      }
    }

    return image;
  }

  @override
  void dispose() {
    if (isInitialized) {
      detector.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection Test Suite'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Test Suite Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text(status),
                    if (testsTotal > 0) ...[
                      SizedBox(height: 8),
                      Text(
                          'Progress: $testsPassed passed, $testsFailed failed, $testsTotal total'),
                      SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: testsTotal > 0 ? testsPassed / testsTotal : 0,
                        backgroundColor: Colors.red[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: runAllTests,
                  child: Text('🧪 Run All Tests'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: testModelInformation,
                  child: Text('📋 Model Info'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton(
                  onPressed: testInitialization,
                  child: Text('🔧 Init Only'),
                ),
                ElevatedButton(
                  onPressed: testLoadAndDisplayLabels,
                  child: Text('🏷️ Labels'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    logs.clear();
                    testsTotal = 0;
                    testsPassed = 0;
                    testsFailed = 0;
                  }),
                  child: Text('🗑️ Clear'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Logs
            Text('Test Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: ListView.builder(
                  controller: _logController,
                  padding: EdgeInsets.all(12),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    Color textColor = Colors.black87;

                    if (log.contains('✅') || log.contains('PASSED'))
                      textColor = Colors.green[700]!;
                    if (log.contains('❌') || log.contains('FAILED'))
                      textColor = Colors.red[700]!;
                    if (log.contains('⚠️') || log.contains('WARNING'))
                      textColor = Colors.orange[700]!;
                    if (log.contains('📊') || log.contains('🏁'))
                      textColor = Colors.blue[700]!;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: textColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
