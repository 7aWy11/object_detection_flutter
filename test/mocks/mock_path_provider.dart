import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MockPathProvider {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/path_provider');

  static void setupMockPathProvider() {
    TestWidgetsFlutterBinding.ensureInitialized();

    _channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getTemporaryDirectory':
          return Directory.systemTemp.path;
        case 'getApplicationDocumentsDirectory':
          return Directory.current.path;
        case 'getApplicationSupportDirectory':
          return Directory.current.path;
        case 'getLibraryDirectory':
          return Directory.current.path;
        case 'getExternalStorageDirectory':
          return Directory.current.path;
        default:
          return null;
      }
    });
  }
}
