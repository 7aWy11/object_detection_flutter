import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Setup mock assets for testing
class MockAssetsSetup {
  static void setupMockAssets() {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock AssetBundle to return fake data for test assets
    final mockBundle = MockAssetBundle();

    // Override the default asset bundle for tests
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter/assets'),
      (call) async {
        if (call.method == 'load') {
          final String assetPath = call.arguments as String;

          if (assetPath == 'assets/model.tflite') {
            // Return a fake TFLite model (just some bytes)
            return Uint8List.fromList(List.generate(1000, (i) => i % 256));
          } else if (assetPath == 'assets/labels.txt') {
            // Return fake labels
            const labels = '''A
B
C
D
E
F
G
H
I
J
K
L
M
N
O
P
Q
R
S
T
U
V
W
X
Y
Z
Delete
Nothing
Space''';
            return Uint8List.fromList(labels.codeUnits);
          }
        }
        return null;
      },
    );
  }
}

class MockAssetBundle extends AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (key == 'assets/labels.txt') {
      return '''A
B
C
D
E
F
G
H
I
J
K
L
M
N
O
P
Q
R
S
T
U
V
W
X
Y
Z
Delete
Nothing
Space''';
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) async {
    if (key == 'assets/model.tflite') {
      // Return fake model data
      final bytes = Uint8List.fromList(List.generate(1000, (i) => i % 256));
      return ByteData.view(bytes.buffer);
    } else if (key == 'assets/labels.txt') {
      const labels = '''A
B
C
D
E
F
G
H
I
J
K
L
M
N
O
P
Q
R
S
T
U
V
W
X
Y
Z
Delete
Nothing
Space''';
      final bytes = Uint8List.fromList(labels.codeUnits);
      return ByteData.view(bytes.buffer);
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  void evict(String key) {}
}
