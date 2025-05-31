import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:object_detection_flutter/object_detection_flutter.dart';
import 'test_utils.dart';

void main() {
  group('IsolateUtils Tests', () {
    late IsolateUtils isolateUtils;

    setUp(() {
      isolateUtils = IsolateUtils();
    });

    tearDown(() {
      isolateUtils.stop();
    });

    test('Initial state', () {
      expect(isolateUtils.sendPort, null);
    });

    test('Start isolate', () async {
      await isolateUtils.start();
      expect(isolateUtils.sendPort, isNotNull);
    });

    test('Start isolate multiple times throws error', () async {
      await isolateUtils.start();
      expect(isolateUtils.sendPort, isNotNull);

      expect(
        () => isolateUtils.start(),
        throwsA(isA<StateError>()),
      );
    });

    test('Stop isolate', () async {
      await isolateUtils.start();
      expect(isolateUtils.sendPort, isNotNull);

      isolateUtils.stop();
      expect(isolateUtils.sendPort, null);
    });

    test('Stop unstarted isolate', () {
      expect(() => isolateUtils.stop(), returnsNormally);
    });

    test('Start and stop multiple times', () async {
      for (var i = 0; i < 3; i++) {
        await isolateUtils.start();
        expect(isolateUtils.sendPort, isNotNull);

        isolateUtils.stop();
        expect(isolateUtils.sendPort, null);
      }
    });

    test('IsolateData creation', () {
      final sendPort = ReceivePort().sendPort;
      final data = IsolateData(
        imageData: Uint8List.fromList([1, 2, 3, 4]),
        interpreterAddress: 123,
        labels: ['label1', 'label2'],
        responsePort: sendPort,
        imageWidth: 100,
        imageHeight: 100,
      );

      expect(data.imageData, isA<Uint8List>());
      expect(data.interpreterAddress, 123);
      expect(data.labels, ['label1', 'label2']);
      expect(data.responsePort, sendPort);
      expect(data.imageWidth, 100);
      expect(data.imageHeight, 100);
    });

    test('IsolateData creation with invalid dimensions throws error', () {
      final sendPort = ReceivePort().sendPort;

      expect(
        () => IsolateData(
          imageData: Uint8List.fromList([1, 2, 3, 4]),
          interpreterAddress: 123,
          labels: ['label1', 'label2'],
          responsePort: sendPort,
          imageWidth: 0,
          imageHeight: 100,
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => IsolateData(
          imageData: Uint8List.fromList([1, 2, 3, 4]),
          interpreterAddress: 123,
          labels: ['label1', 'label2'],
          responsePort: sendPort,
          imageWidth: 100,
          imageHeight: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('IsolateData creation with invalid interpreter address throws error',
        () {
      final sendPort = ReceivePort().sendPort;

      expect(
        () => IsolateData(
          imageData: Uint8List.fromList([1, 2, 3, 4]),
          interpreterAddress: 0,
          labels: ['label1', 'label2'],
          responsePort: sendPort,
          imageWidth: 100,
          imageHeight: 100,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('IsolateData creation with empty image data throws error', () {
      final sendPort = ReceivePort().sendPort;

      expect(
        () => IsolateData(
          imageData: Uint8List(0),
          interpreterAddress: 123,
          labels: ['label1', 'label2'],
          responsePort: sendPort,
          imageWidth: 100,
          imageHeight: 100,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('IsolateData creation with empty labels throws error', () {
      final sendPort = ReceivePort().sendPort;

      expect(
        () => IsolateData(
          imageData: Uint8List.fromList([1, 2, 3, 4]),
          interpreterAddress: 123,
          labels: [],
          responsePort: sendPort,
          imageWidth: 100,
          imageHeight: 100,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('IsolateData equality comparison', () {
      final sendPort = ReceivePort().sendPort;
      final data1 = IsolateData(
        imageData: Uint8List.fromList([1, 2, 3, 4]),
        interpreterAddress: 123,
        labels: ['label1', 'label2'],
        responsePort: sendPort,
        imageWidth: 100,
        imageHeight: 100,
      );

      final data2 = IsolateData(
        imageData: Uint8List.fromList([1, 2, 3, 4]),
        interpreterAddress: 123,
        labels: ['label1', 'label2'],
        responsePort: sendPort,
        imageWidth: 100,
        imageHeight: 100,
      );

      final data3 = IsolateData(
        imageData: Uint8List.fromList([5, 6, 7, 8]),
        interpreterAddress: 456,
        labels: ['label3', 'label4'],
        responsePort: sendPort,
        imageWidth: 200,
        imageHeight: 200,
      );

      expect(data1, equals(data2));
      expect(data1, isNot(equals(data3)));
      expect(data1.hashCode, equals(data2.hashCode));
      expect(data1.hashCode, isNot(equals(data3.hashCode)));
    });
  });
}
