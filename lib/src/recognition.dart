import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Represents a detected object with its bounding box and confidence score
class Recognition {
  /// Unique identifier for the detection
  final int id;

  /// Label of the detected object
  final String label;

  /// Confidence score of the detection (0.0 to 1.0)
  final double score;

  /// Bounding box of the detection in the original image
  final Rect location;

  /// Bounding box scaled to the screen size
  late Rect renderLocation;

  /// Face landmarks (for face detection) - typically 5 points
  final List<Offset>? landmarks;
  
  /// Face landmarks scaled to screen size
  late List<Offset>? renderLandmarks;
  
  /// Human pose keypoints (for pose estimation) - typically 17 COCO keypoints
  final List<Offset>? keypoints;
  
  /// Human pose keypoints scaled to screen size
  late List<Offset>? renderKeypoints;
  
  /// Segmentation mask pixel locations (for segmentation)
  final List<Offset>? segmentationMask;
  
  /// Segmentation mask scaled to screen size
  late List<Offset>? renderSegmentationMask;
  
  /// Additional metadata
  final Map<String, dynamic>? metadata;

  /// Main constructor (backward compatible)
  Recognition({
    required this.id,
    required this.label,
    required this.score,
    required this.location,
    this.landmarks,
    this.keypoints,
    this.segmentationMask,
    this.metadata,
  }) {
    // Initialize render variables
    renderLandmarks = null;
    renderKeypoints = null;
    renderSegmentationMask = null;
  }

  /// Create Recognition for face detection
  factory Recognition.faceDetection({
    required int id,
    required double score,
    required Rect location,
    List<Offset>? landmarks,
  }) {
    return Recognition(
      id: id,
      label: "Face",
      score: score,
      location: location,
      landmarks: landmarks,
    );
  }

  /// Create Recognition for pose estimation
  factory Recognition.poseEstimation({
    required int id,
    required double score,
    required Rect location,
    required List<Offset> keypoints,
  }) {
    return Recognition(
      id: id,
      label: "Person",
      score: score,
      location: location,
      keypoints: keypoints,
    );
  }

  /// Create Recognition for segmentation
  factory Recognition.segmentation({
    required int id,
    required String label,
    required double score,
    required Rect location,
    List<Offset>? segmentationMask,
  }) {
    return Recognition(
      id: id,
      label: label,
      score: score,
      location: location,
      segmentationMask: segmentationMask,
    );
  }

  /// Update the render location and all other render coordinates based on screen and image sizes
  void updateRenderLocation(ui.Size imageSize, ui.Size screenSize) {
    final double scaleX = screenSize.width / imageSize.width;
    final double scaleY = screenSize.height / imageSize.height;

    // Update bounding box (always present)
    renderLocation = Rect.fromLTRB(
      location.left * scaleX,
      location.top * scaleY,
      location.right * scaleX,
      location.bottom * scaleY,
    );

    // Update landmarks
    if (landmarks != null) {
      renderLandmarks = landmarks!.map((landmark) => Offset(
        landmark.dx * scaleX,
        landmark.dy * scaleY,
      )).toList();
    }

    // Update keypoints
    if (keypoints != null) {
      renderKeypoints = keypoints!.map((keypoint) => Offset(
        keypoint.dx * scaleX,
        keypoint.dy * scaleY,
      )).toList();
    }

    // Update segmentation mask
    if (segmentationMask != null) {
      renderSegmentationMask = segmentationMask!.map((point) => Offset(
        point.dx * scaleX,
        point.dy * scaleY,
      )).toList();
    }
  }

  /// Check if this recognition has landmarks
  bool get hasLandmarks => landmarks != null && landmarks!.isNotEmpty;
  
  /// Check if this recognition has keypoints
  bool get hasKeypoints => keypoints != null && keypoints!.isNotEmpty;
  
  /// Check if this recognition has segmentation mask
  bool get hasSegmentationMask => segmentationMask != null && segmentationMask!.isNotEmpty;

  /// Get the area of the bounding box
  double get area => location.width * location.height;

  /// Get center point of bounding box
  Offset get center => location.center;

  /// Get the area of the render bounding box
  double get renderArea => renderLocation.width * renderLocation.height;

  /// Get center point of render bounding box
  Offset get renderCenter => renderLocation.center;

  /// Convert to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'score': score,
      'location': {
        'left': location.left,
        'top': location.top,
        'right': location.right,
        'bottom': location.bottom,
      },
      'landmarks': landmarks?.map((point) => {
        'x': point.dx,
        'y': point.dy,
      }).toList(),
      'keypoints': keypoints?.map((point) => {
        'x': point.dx,
        'y': point.dy,
      }).toList(),
      'segmentationMask': segmentationMask?.map((point) => {
        'x': point.dx,
        'y': point.dy,
      }).toList(),
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, score: ${score.toStringAsFixed(3)}, location: $location)';
  }
}