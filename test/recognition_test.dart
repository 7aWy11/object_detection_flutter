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

    test('Create Recognition with invalid score throws error', () {
      expect(
        () => Recognition(
          id: 1,
          label: 'person',
          score: -0.1,
          location: Rect.fromLTRB(10, 20, 30, 40),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => Recognition(
          id: 1,
          label: 'person',
          score: 1.1,
          location: Rect.fromLTRB(10, 20, 30, 40),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('Create Recognition with invalid location throws error', () {
      expect(
        () => Recognition(
          id: 1,
          label: 'person',
          score: 0.95,
          location: Rect.fromLTRB(30, 20, 10, 40), // Invalid: left > right
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => Recognition(
          id: 1,
          label: 'person',
          score: 0.95,
          location: Rect.fromLTRB(10, 40, 30, 20), // Invalid: top > bottom
        ),
        throwsA(isA<AssertionError>()),
      );
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

    test('Update render location with zero size throws error', () {
      final recognition = Recognition(
        id: 1,
        label: 'person',
        score: 0.95,
        location: Rect.fromLTRB(10, 20, 30, 40),
      );

      expect(
        () => recognition.updateRenderLocation(
          const Size(0, 100),
          const Size(200, 200),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => recognition.updateRenderLocation(
          const Size(100, 0),
          const Size(200, 200),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => recognition.updateRenderLocation(
          const Size(100, 100),
          const Size(0, 200),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => recognition.updateRenderLocation(
          const Size(100, 100),
          const Size(200, 0),
        ),
        throwsA(isA<AssertionError>()),
      );
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

    test('Equality comparison', () {
      final recognition1 = Recognition(
        id: 1,
        label: 'person',
        score: 0.95,
        location: Rect.fromLTRB(10, 20, 30, 40),
      );

      final recognition2 = Recognition(
        id: 1,
        label: 'person',
        score: 0.95,
        location: Rect.fromLTRB(10, 20, 30, 40),
      );

      final recognition3 = Recognition(
        id: 2,
        label: 'car',
        score: 0.85,
        location: Rect.fromLTRB(50, 60, 70, 80),
      );

      expect(recognition1, equals(recognition2));
      expect(recognition1, isNot(equals(recognition3)));
      expect(recognition1.hashCode, equals(recognition2.hashCode));
      expect(recognition1.hashCode, isNot(equals(recognition3.hashCode)));
    });

    test('Copy with method', () {
      final original = Recognition(
        id: 1,
        label: 'person',
        score: 0.95,
        location: Rect.fromLTRB(10, 20, 30, 40),
      );

      final copy = original.copyWith(
        id: 2,
        label: 'car',
        score: 0.85,
        location: Rect.fromLTRB(50, 60, 70, 80),
      );

      expect(copy.id, 2);
      expect(copy.label, 'car');
      expect(copy.score, 0.85);
      expect(copy.location, Rect.fromLTRB(50, 60, 70, 80));

      // Original should remain unchanged
      expect(original.id, 1);
      expect(original.label, 'person');
      expect(original.score, 0.95);
      expect(original.location, Rect.fromLTRB(10, 20, 30, 40));
    });

    test('Copy with partial updates', () {
      final original = Recognition(
        id: 1,
        label: 'person',
        score: 0.95,
        location: Rect.fromLTRB(10, 20, 30, 40),
      );

      final copy = original.copyWith(
        id: 2,
        score: 0.85,
      );

      expect(copy.id, 2);
      expect(copy.label, 'person'); // Unchanged
      expect(copy.score, 0.85);
      expect(copy.location, Rect.fromLTRB(10, 20, 30, 40)); // Unchanged
    });
  });
}
