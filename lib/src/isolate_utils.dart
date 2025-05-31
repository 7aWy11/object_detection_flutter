import 'dart:isolate';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imageLib;
import 'classifier.dart';
import 'recognition.dart';

/// Data class for passing information to isolate
class IsolateData {
  final Uint8List imageData;
  final int interpreterAddress;
  final List<String> labels;
  final SendPort responsePort;
  final int imageWidth;
  final int imageHeight;

  IsolateData({
    required this.imageData,
    required this.interpreterAddress,
    required this.labels,
    required this.responsePort,
    required this.imageWidth,
    required this.imageHeight,
  });
}

/// Utility class for handling isolate operations
class IsolateUtils {
  Isolate? _isolate;
  SendPort? sendPort;
  ReceivePort? _receivePort;

  /// Start the isolate for model inference
  Future<void> start() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _isolateEntryPoint,
      _receivePort!.sendPort,
    );

    sendPort = await _receivePort!.first;
  }

  /// Stop the isolate
  void stop() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    sendPort = null;
    _receivePort?.close();
    _receivePort = null;
  }
}

/// Entry point for the isolate
void _isolateEntryPoint(SendPort sendPort) async {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (final IsolateData isolateData in port) {
    try {
      // Create classifier with interpreter from address
      final classifier = Classifier(
        interpreter: Interpreter.fromAddress(isolateData.interpreterAddress),
        labels: isolateData.labels,
      );

      // Decode image from bytes
      final image = imageLib.decodeImage(isolateData.imageData);

      if (image != null) {
        // Perform prediction
        final results = classifier.predict(image);

        // Send results back
        isolateData.responsePort.send(results);
      } else {
        isolateData.responsePort.send({
          "recognitions": <Recognition>[],
          "stats": null,
          "error": "Failed to decode image"
        });
      }
    } catch (e) {
      isolateData.responsePort.send({
        "recognitions": <Recognition>[],
        "stats": null,
        "error": e.toString()
      });
    }
  }
}
