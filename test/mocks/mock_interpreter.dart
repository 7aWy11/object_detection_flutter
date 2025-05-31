import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Mock implementation of the Interpreter class for testing
class MockInterpreter implements Interpreter {
  final List<List<int>> inputShapes;
  final List<List<int>> outputShapes;
  final List<int> inputTypes;
  final List<int> outputTypes;

  MockInterpreter({
    this.inputShapes = const [
      [1, 300, 300, 3]
    ],
    this.outputShapes = const [
      [1, 10, 4],
      [1, 10],
      [1, 10],
      [1]
    ],
    this.inputTypes = const [1],
    this.outputTypes = const [1, 1, 1, 1],
  });

  @override
  int get address => 12345;

  @override
  void allocateTensors() {}

  @override
  void close() {}

  @override
  void delete() {}

  @override
  void dispose() {}

  @override
  int get inputTensorCount => 1;

  @override
  List<int> get inputShape => [1, 224, 224, 3];

  @override
  TensorType get inputTensorType => TensorType.float32;

  @override
  int get outputTensorCount => 1;

  @override
  List<int> get outputShape => [1, 10];

  @override
  TensorType get outputTensorType => TensorType.float32;

  @override
  void invoke() {}

  @override
  void resetAllVariables() {}

  @override
  void resizeInputTensor(int index, List<int> shape) {}

  @override
  void setInputTensor(int index, dynamic value) {}

  @override
  Tensor getOutputTensor(int index) {
    return MockTensor();
  }

  @override
  void setTensor(int index, dynamic value) {}

  @override
  Tensor getTensor(int index) {
    return MockTensor();
  }

  @override
  int getInputIndex(String name) => 0;

  @override
  Tensor getInputTensor(int index) => MockTensor();

  @override
  int getOutputIndex(String name) => 0;

  @override
  void resetVariableTensors() {}

  @override
  List<Tensor> getInputTensors() => [MockTensor()];

  @override
  List<Tensor> getOutputTensors() => [MockTensor()];

  @override
  void run(Object input, Object output) {}

  @override
  void runForMultipleInputs(List<Object> inputs, Map<int, Object> outputs) {}

  @override
  void runInference(List<Object> inputs) {}

  @override
  bool get isAllocated => true;

  @override
  bool get isDeleted => false;

  @override
  int get lastNativeInferenceDurationMicroSeconds => 0;
}

/// Mock implementation of the Tensor class for testing
class MockTensor implements Tensor {
  @override
  int get address => 12345;

  @override
  void delete() {}

  @override
  void dispose() {}

  @override
  List<int> get shape => [1, 224, 224, 3];

  @override
  TensorType get type => TensorType.float32;

  @override
  Uint8List get data => Uint8List(10);

  @override
  set data(Uint8List value) {}

  @override
  void copyFrom(Object src) {}

  @override
  Object copyTo(Object dst) => dst;

  @override
  List<int>? getInputShapeIfDifferent(Object? shape) => null;

  @override
  int numBytes() => 10;

  @override
  int numDimensions() => 4;

  @override
  int numElements() => 10;

  @override
  void quantize(List<double> scale, List<int> zeroPoint) {}

  @override
  void dequantize(List<double> scale, List<int> zeroPoint) {}

  @override
  void setTo(Object src) {}

  @override
  Object getData() => Uint8List(10);

  @override
  String get name => 'mock_tensor';

  @override
  QuantizationParams get params => QuantizationParams(0.0, 0);
}
