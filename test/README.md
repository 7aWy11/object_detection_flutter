# 🧪 Test Directory

## ⚠️ Current Status: Windows Compatibility Issue

The test files in this directory are currently **not functional on Windows** due to TensorFlow Lite compatibility issues.

### 🐛 The Problem

When running tests on Windows, you'll encounter this error:

```bash
Invalid argument(s): Failed to load dynamic library 
'C:\src\flutter\bin\cache\artifacts\engine\windows-x64/blobs/libtensorflowlite_c-win.dll': 
The specified module could not be found. (error code: 126)
```

### 🔍 Root Cause

- **TensorFlow Lite Windows DLL**: The required `libtensorflowlite_c-win.dll` is missing from Flutter's Windows artifacts
- **Flutter Test Runner**: Executes on the host machine (Windows) rather than the target device (Android)
- **Platform Detection**: Standard platform detection doesn't work properly in Flutter test environment

### ✅ Working Alternative

We've implemented a **comprehensive test suite** as a Flutter app that runs directly on Android devices. This provides:

- ✅ **Real TensorFlow Lite testing** on Android
- ✅ **Performance benchmarks** with actual hardware
- ✅ **Complete test coverage** of all functionality
- ✅ **Visual feedback** and detailed logging

**📍 Location**: `../example/object_detection_test_app/`

### 🚀 How to Test (Recommended Approach)

Instead of using these test files, use our Android test app:

```bash
# Navigate to the test app
cd example/object_detection_test_app/

# Run on Android emulator/device
flutter run --device-id=emulator-5554

# Tap "🧪 Run All Tests" in the app
```

## 🤝 Contributing

### 💡 Can You Help Solve This?

If you have experience with:
- 🔧 **Windows TensorFlow Lite compilation**
- 🏗️ **Flutter Windows engine development**
- 🧩 **FFI and native library integration**
- 📦 **Cross-platform Flutter testing**

**We'd love your contribution!** 

### 🎯 What We Need

1. **Build TensorFlow Lite DLL** for Windows with proper symbol exports
2. **Fix Flutter test platform detection** for device-specific testing
3. **Alternative testing strategies** that work across platforms
4. **CI/CD integration** for automated testing

### 📝 How to Contribute

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b fix/windows-tflite-tests`
3. **Implement your solution**
4. **Test thoroughly** on Windows, Android, and iOS
5. **Submit a pull request** with detailed explanation

### 🔗 Useful Resources

- [TensorFlow Lite Windows Build Guide](https://www.tensorflow.org/lite/guide/build_cmake)
- [Flutter Desktop Development](https://docs.flutter.dev/desktop)
- [Flutter Testing Best Practices](https://docs.flutter.dev/testing)
- [FFI in Flutter](https://docs.flutter.dev/development/platform-integration/c-interop)

## 📁 Test Files Structure

```
test/
├── README.md                    # This file
├── classifier_test.dart         # ❌ Currently broken on Windows
├── detector_test.dart           # ❌ Currently broken on Windows  
├── example_test.dart            # ❌ Currently broken on Windows
├── detection_painter_test.dart  # ✅ Works (no TensorFlow dependency)
├── recognition_test.dart        # ✅ Works (no TensorFlow dependency)
├── stats_test.dart              # ✅ Works (no TensorFlow dependency)
└── mocks/                       # Mock implementations
    ├── mock_classifier.dart
    ├── mock_interpreter.dart
    └── mock_path_provider.dart
```

### 📊 Test Status

| Test File | Windows | Android | iOS | Status |
|-----------|---------|---------|-----|--------|
| `classifier_test.dart` | ❌ | ✅ | ✅ | TensorFlow dependent |
| `detector_test.dart` | ❌ | ✅ | ✅ | TensorFlow dependent |
| `example_test.dart` | ❌ | ✅ | ✅ | TensorFlow dependent |
| `detection_painter_test.dart` | ✅ | ✅ | ✅ | Platform independent |
| `recognition_test.dart` | ✅ | ✅ | ✅ | Platform independent |
| `stats_test.dart` | ✅ | ✅ | ✅ | Platform independent |

## 🎖️ Hall of Fame

*Contributors who solve the Windows TensorFlow Lite testing issue will be listed here!*

---

### 💬 Questions or Ideas?

- **Open an issue** to discuss potential solutions
- **Join the discussion** in existing related issues
- **Share your experience** with Windows TensorFlow Lite builds

**Together, we can make Flutter object detection testing work seamlessly across all platforms!** 🌟