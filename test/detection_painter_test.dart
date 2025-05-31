import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:object_detection_flutter/object_detection_flutter.dart';

void main() {
  group('DetectionPainter Tests', () {
    test('Create DetectionPainter with valid parameters', () {
      final detectionResults = [
        Recognition(
          id: 1,
          label: 'person',
          score: 0.95,
          location: Rect.fromLTWH(0.1, 0.2, 0.3, 0.4),
        ),
      ];
      final imageSize = ui.Size(640, 480);
      final screenSize = ui.Size(320, 240);

      final painter = DetectionPainter(
        detectionResults: detectionResults,
        imageSize: imageSize,
        screenSize: screenSize,
      );

      expect(painter.detectionResults, detectionResults);
      expect(painter.imageSize, imageSize);
      expect(painter.screenSize, screenSize);
    });

    test('shouldRepaint returns true when detection results change', () {
      final detectionResults1 = [
        Recognition(
          id: 1,
          label: 'person',
          score: 0.95,
          location: Rect.fromLTWH(0.1, 0.2, 0.3, 0.4),
        ),
      ];
      final detectionResults2 = [
        Recognition(
          id: 2,
          label: 'car',
          score: 0.85,
          location: Rect.fromLTWH(0.2, 0.3, 0.4, 0.5),
        ),
      ];
      final imageSize = ui.Size(640, 480);
      final screenSize = ui.Size(320, 240);

      final painter1 = DetectionPainter(
        detectionResults: detectionResults1,
        imageSize: imageSize,
        screenSize: screenSize,
      );

      final painter2 = DetectionPainter(
        detectionResults: detectionResults2,
        imageSize: imageSize,
        screenSize: screenSize,
      );

      expect(painter1.shouldRepaint(painter2), true);
    });

    test('shouldRepaint returns true when image size changes', () {
      final detectionResults = [
        Recognition(
          id: 1,
          label: 'person',
          score: 0.95,
          location: Rect.fromLTWH(0.1, 0.2, 0.3, 0.4),
        ),
      ];
      final imageSize1 = ui.Size(640, 480);
      final imageSize2 = ui.Size(800, 600);
      final screenSize = ui.Size(320, 240);

      final painter1 = DetectionPainter(
        detectionResults: detectionResults,
        imageSize: imageSize1,
        screenSize: screenSize,
      );

      final painter2 = DetectionPainter(
        detectionResults: detectionResults,
        imageSize: imageSize2,
        screenSize: screenSize,
      );

      expect(painter1.shouldRepaint(painter2), true);
    });

    test('shouldRepaint returns true when screen size changes', () {
      final detectionResults = [
        Recognition(
          id: 1,
          label: 'person',
          score: 0.95,
          location: Rect.fromLTWH(0.1, 0.2, 0.3, 0.4),
        ),
      ];
      final imageSize = ui.Size(640, 480);
      final screenSize1 = ui.Size(320, 240);
      final screenSize2 = ui.Size(480, 360);

      final painter1 = DetectionPainter(
        detectionResults: detectionResults,
        imageSize: imageSize,
        screenSize: screenSize1,
      );

      final painter2 = DetectionPainter(
        detectionResults: detectionResults,
        imageSize: imageSize,
        screenSize: screenSize2,
      );

      expect(painter1.shouldRepaint(painter2), true);
    });

    test('shouldRepaint returns false when nothing changes', () {
      final detectionResults = [
        Recognition(
          id: 1,
          label: 'person',
          score: 0.95,
          location: Rect.fromLTWH(0.1, 0.2, 0.3, 0.4),
        ),
      ];
      final imageSize = ui.Size(640, 480);
      final screenSize = ui.Size(320, 240);

      final painter1 = DetectionPainter(
        detectionResults: detectionResults,
        imageSize: imageSize,
        screenSize: screenSize,
      );

      final painter2 = DetectionPainter(
        detectionResults: detectionResults,
        imageSize: imageSize,
        screenSize: screenSize,
      );

      expect(painter1.shouldRepaint(painter2), false);
    });
  });
}
