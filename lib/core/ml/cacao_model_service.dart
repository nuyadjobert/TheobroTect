import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';

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
    "non_cacao",
  ];

  Future<void> loadModel() async {
    if (_isLoaded) return;
    _interpreter = await Interpreter.fromAsset(
      'assets/models/mobilenetv3large_trainmodelV7.tflite',
      options: InterpreterOptions()..threads = 2,
    );
    _isLoaded = true;

    // ✅ ADDED: Debug tensor info on load
    final inputTensor = _interpreter!.getInputTensor(0);
    final outputTensor = _interpreter!.getOutputTensor(0);
    debugPrint("Model loaded.");
    debugPrint("  Input shape : ${inputTensor.shape}");
    debugPrint("  Input type  : ${inputTensor.type}");
    debugPrint("  Output shape: ${outputTensor.shape}");
    debugPrint("  Output type : ${outputTensor.type}");
  }

  Future<ModelPrediction> predict(String imagePath) async {
    if (!_isLoaded || _interpreter == null) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Failed to decode image.');
    }

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
          return [
            pixel.r.toDouble(),  // raw 0–255
            pixel.g.toDouble(),  // raw 0–255
            pixel.b.toDouble(),  // raw 0–255
          ];
        }),
      ),
    );

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

    // ✅ CHANGED: Log ALL scores instead of only non_cacao alert
    debugPrint("=== RAW SCORES ===");
    for (int i = 0; i < scores.length; i++) {
      debugPrint(
        "  [$i] ${labelsInOrder[i]}: ${(scores[i] * 100).toStringAsFixed(2)}%",
      );
    }
    debugPrint(
      "=== BEST: $bestLabel @ ${(bestScore * 100).toStringAsFixed(1)}% ===",
    );

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

  bool get isNonCacao => label == "non_cacao";
}