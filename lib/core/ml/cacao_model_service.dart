import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class CacaoModelService {
  static final CacaoModelService _instance = CacaoModelService._internal();
  factory CacaoModelService() => _instance;
  CacaoModelService._internal();

  Interpreter? _interpreter;
  bool _isLoaded = false;

  static const List<String> labelsInOrder = [
    "black_pod_disease_mild",
    "black_pod_disease_moderate",
    "black_pod_disease_severe",
    "cacao_pod_borer_mild",
    "cacao_pod_borer_moderate",
    "cacao_pod_borer_severe",
    "healthy",
    "mealybug_mild",
    "mealybug_moderate",
    "mealybug_severe",
  ];

  Future<void> loadModel() async {
    if (_isLoaded) return;
    _interpreter = await Interpreter.fromAsset(
      'assets/models/final_cacao_disease_model1.0.tflite',
      options: InterpreterOptions()..threads = 2,
    );

    _isLoaded = true;

    // (Optional) debug: check shapes/types
    final inT = _interpreter!.getInputTensor(0);
    final outT = _interpreter!.getOutputTensor(0);
    // ignore: avoid_print
    print('✅ input: shape=${inT.shape} type=${inT.type}');
    // ignore: avoid_print
    print('✅ output: shape=${outT.shape} type=${outT.type}');
  }

  /// Run inference on an image file.
  /// Assumes float32 model with input [1, H, W, 3] normalized 0..1
  Future<ModelPrediction> predict(String imagePath) async {
    if (!_isLoaded || _interpreter == null) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    // Read image
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode image.');
    }

    // Detect input size from model tensor shape: [1, H, W, 3]
    final inputTensor = _interpreter!.getInputTensor(0);
    final shape = inputTensor.shape;
    final h = shape[1];
    final w = shape[2];

    final resized = img.copyResize(decoded, width: w, height: h);

    final input = List.generate(
      1,
      (_) => List.generate(
        h,
        (y) => List.generate(w, (x) {
          final pixel = resized.getPixel(x, y);

          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    // Output tensor [1][numLabels]
    final numLabels = labelsInOrder.length;
    final output = List.generate(1, (_) => List.filled(numLabels, 0.0));

    _interpreter!.run(input, output);

    final scores = output[0];
    int bestIdx = 0;
    double bestScore = scores[0];

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIdx = i;
      }
    }

    bestScore = max(0.0, min(1.0, bestScore));
    final bestLabel = labelsInOrder[bestIdx];

    return ModelPrediction(
      label: bestLabel,
      confidence: bestScore,
      index: bestIdx,
    );
  }
}

class ModelPrediction {
  final String label;
  final double confidence;
  final int index;

  ModelPrediction({
    required this.label,
    required this.confidence,
    required this.index,
  });
}
