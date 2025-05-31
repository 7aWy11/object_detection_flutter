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

    test('Stop isolate', () async {
      await isolateUtils.start();
      expect(isolateUtils.sendPort, isNotNull);

      isolateUtils.stop();
      expect(isolateUtils.sendPort, null);
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
  });
}
