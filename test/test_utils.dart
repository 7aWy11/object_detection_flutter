import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Helper class for test utilities
class TestUtils {
  /// Get the test assets directory
  static Future<String> getTestAssetsPath() async {
    final directory = await getTemporaryDirectory();
    final testAssetsPath = path.join(directory.path, 'test_assets');
    await Directory(testAssetsPath).create(recursive: true);
    return testAssetsPath;
  }

  /// Copy test assets to temporary directory
  static Future<void> setupTestAssets() async {
    final testAssetsPath = await getTestAssetsPath();

    // Copy model file
    final modelBytes = await rootBundle.load('assets/model.tflite');
    final modelFile = File(path.join(testAssetsPath, 'model.tflite'));
    await modelFile.writeAsBytes(
      modelBytes.buffer.asUint8List(
        modelBytes.offsetInBytes,
        modelBytes.lengthInBytes,
      ),
    );

    // Copy labels file
    final labelsBytes = await rootBundle.load('assets/labels.txt');
    final labelsFile = File(path.join(testAssetsPath, 'labels.txt'));
    await labelsFile.writeAsBytes(
      labelsBytes.buffer.asUint8List(
        labelsBytes.offsetInBytes,
        labelsBytes.lengthInBytes,
      ),
    );
  }

  /// Create a test image
  static Future<Uint8List> createTestImage() async {
    // Create a simple test image (1x1 pixel)
    final bytes = Uint8List.fromList([
      255, 0, 0, 255, // Red pixel
    ]);
    return bytes;
  }

  /// Clean up test assets
  static Future<void> cleanupTestAssets() async {
    final testAssetsPath = await getTestAssetsPath();
    await Directory(testAssetsPath).delete(recursive: true);
  }
}
