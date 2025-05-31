import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:object_detection_flutter/object_detection_flutter.dart';

void main() {
  group('Recognition Tests', () {
    test('Create Recognition instance', () {
      final recognition = Recognition(
        id: 1,
        label: 'person',
        score: 0.95,
        location: Rect.fromLTRB(10, 20, 30, 40),
      );

      expect(recognition.id, 1);
      expect(recognition.label, 'person');
      expect(recognition.score, 0.95);
      expect(recognition.location, Rect.fromLTRB(10, 20, 30, 40));
    });

    test('Update render location', () {
      final recognition = Recognition(
        id: 1,
        label: 'person',
        score: 0.95,
        location: Rect.fromLTRB(10, 20, 30, 40),
      );

      recognition.updateRenderLocation(
        const Size(100, 100),
        const Size(200, 200),
      );

      expect(recognition.renderLocation, Rect.fromLTRB(20, 40, 60, 80));
    });

    test('Update render location with different aspect ratios', () {
      final recognition = Recognition(
        id: 1,
        label: 'person',
        score: 0.95,
        location: Rect.fromLTRB(10, 20, 30, 40),
      );

      recognition.updateRenderLocation(
        const Size(100, 200),
        const Size(200, 100),
      );

      expect(recognition.renderLocation, Rect.fromLTRB(20, 10, 60, 20));
    });

    test('ToString representation', () {
      final recognition = Recognition(
        id: 1,
        label: 'person',
        score: 0.95,
        location: Rect.fromLTRB(10, 20, 30, 40),
      );

      expect(
        recognition.toString(),
        'Recognition(id: 1, label: person, score: 0.95, location: Rect.fromLTRB(10.0, 20.0, 30.0, 40.0))',
      );
    });
  });
}
