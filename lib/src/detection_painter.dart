import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'recognition.dart';

/// CustomPainter for drawing detection results on the canvas
class DetectionPainter extends CustomPainter {
  /// List of detected objects
  final List<Recognition> detectionResults;

  /// Size of the preview image
  final ui.Size imageSize;

  /// Size of the screen
  final ui.Size screenSize;

  /// Whether to show landmarks for face detection
  final bool showLandmarks;

  /// Whether to show keypoints for pose estimation
  final bool showKeypoints;

  /// Whether to show segmentation masks
  final bool showSegmentationMask;

  DetectionPainter({
    required this.detectionResults,
    required this.imageSize,
    required this.screenSize,
    this.showLandmarks = true,
    this.showKeypoints = true,
    this.showSegmentationMask = false, // Usually too cluttered for real-time display
  });

  @override
  void paint(Canvas canvas, ui.Size size) {
    final Paint boxPaint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint landmarkPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final Paint keypointPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final Paint bonePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint segmentationPaint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    final Paint textBackground = Paint()..color = Colors.black.withOpacity(0.7);

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (final detection in detectionResults) {
      // Update render location for this detection
      detection.updateRenderLocation(imageSize, screenSize);

      // Generate a color based on the detection label
      final color = Colors.primaries[(detection.label.length +
              detection.label.codeUnitAt(0) +
              detection.id) %
          Colors.primaries.length];

      // Update box paint color
      boxPaint.color = color;

      // Draw bounding box
      canvas.drawRect(detection.renderLocation, boxPaint);

      // Draw face landmarks if available
      if (showLandmarks && detection.hasLandmarks && detection.renderLandmarks != null) {
        for (final landmark in detection.renderLandmarks!) {
          canvas.drawCircle(landmark, 4.0, landmarkPaint);
        }
      }

      // Draw pose keypoints and skeleton if available
      if (showKeypoints && detection.hasKeypoints && detection.renderKeypoints != null) {
        final keypoints = detection.renderKeypoints!;
        
        // Draw keypoints
        for (final keypoint in keypoints) {
          canvas.drawCircle(keypoint, 5.0, keypointPaint);
        }

        // Draw skeleton connections (COCO format)
        if (keypoints.length >= 17) {
          _drawPoseSkeleton(canvas, keypoints, bonePaint);
        }
      }

      // Draw segmentation mask if available
      if (showSegmentationMask && detection.hasSegmentationMask && detection.renderSegmentationMask != null) {
        for (final point in detection.renderSegmentationMask!) {
          canvas.drawCircle(point, 1.0, segmentationPaint);
        }
      }

      // Draw label and score
      final labelText = detection.hasKeypoints 
          ? '${detection.label} (Pose) ${(detection.score * 100).toStringAsFixed(1)}%'
          : detection.hasLandmarks
              ? '${detection.label} (Face) ${(detection.score * 100).toStringAsFixed(1)}%'
              : '${detection.label} ${(detection.score * 100).toStringAsFixed(1)}%';

      textPainter.text = TextSpan(
        text: labelText,
        style: textStyle,
      );

      textPainter.layout();

      // Calculate text position
      final textX = detection.renderLocation.left;
      final textY = detection.renderLocation.top - textPainter.height - 4;

      // Draw text background
      final textRect = Rect.fromLTWH(
        textX,
        textY,
        textPainter.width + 8,
        textPainter.height + 4,
      );
      canvas.drawRect(textRect, textBackground);

      // Draw text
      textPainter.paint(
        canvas,
        Offset(textX + 4, textY + 2),
      );
    }
  }

  /// Draw pose skeleton connections based on COCO keypoints format
  void _drawPoseSkeleton(Canvas canvas, List<Offset> keypoints, Paint paint) {
    if (keypoints.length < 17) return;

    // COCO pose connections
    final List<List<int>> connections = [
      // Head
      [0, 1], [0, 2], [1, 3], [2, 4], // nose to eyes to ears
      
      // Torso
      [5, 6], [5, 11], [6, 12], [11, 12], // shoulders to hips
      
      // Left arm
      [5, 7], [7, 9], // left shoulder to elbow to wrist
      
      // Right arm
      [6, 8], [8, 10], // right shoulder to elbow to wrist
      
      // Left leg
      [11, 13], [13, 15], // left hip to knee to ankle
      
      // Right leg
      [12, 14], [14, 16], // right hip to knee to ankle
    ];

    for (final connection in connections) {
      final startIdx = connection[0];
      final endIdx = connection[1];
      
      if (startIdx < keypoints.length && endIdx < keypoints.length) {
        final start = keypoints[startIdx];
        final end = keypoints[endIdx];
        
        // Only draw connection if both keypoints are visible (not at origin)
        if (start.dx > 0 && start.dy > 0 && end.dx > 0 && end.dy > 0) {
          canvas.drawLine(start, end, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DetectionPainter oldDelegate) {
    return oldDelegate.detectionResults != detectionResults ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.screenSize != screenSize ||
        oldDelegate.showLandmarks != showLandmarks ||
        oldDelegate.showKeypoints != showKeypoints ||
        oldDelegate.showSegmentationMask != showSegmentationMask;
  }
}