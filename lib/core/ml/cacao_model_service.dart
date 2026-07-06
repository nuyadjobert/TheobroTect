import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';
import '../model/prediction.model.dart';

enum ConfidenceLevel {
  low,
  medium,
  high,
}

class CacaoModelService {
  static final CacaoModelService _instance = CacaoModelService._internal();
  factory CacaoModelService() => _instance;
  CacaoModelService._internal();

  String getDiseaseFamily(String label) {
    if (label.startsWith('mealybug')) {
      return 'mealybug';
    }

    if (label.startsWith('cacao_pod_borer')) {
      return 'cacao_pod_borer';
    }

    if (label.startsWith('black_pod_disease')) {
      return 'black_pod_disease';
    }

    return label;
  }

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
      // 'assets/models/mobilenetv3large_retrain_V7.tflite',
      // 'assets/models/mobilenetv3large_retrain_V8.tflite',
      'assets/models/mobilenetv3large_retrain_V9.tflite',
      // 'assets/models/mobilenetv3large_modelv1.tflite',
      // 'assets/models/mobilenetv3large_augmented_V8.tflite',
      // 'assets/models/mobilenetv3large_retrain_V5_augmented.tflite',
      options: InterpreterOptions()..threads = 2,
    );
    _isLoaded = true;

    final inputTensor = _interpreter!.getInputTensor(0);
    final outputTensor = _interpreter!.getOutputTensor(0);
    debugPrint("Model loaded.");
    debugPrint("  Input shape : ${inputTensor.shape}");
    debugPrint("  Input type  : ${inputTensor.type}");
    debugPrint("  Output shape: ${outputTensor.shape}");
    debugPrint("  Output type : ${outputTensor.type}");
  }

  ConfidenceLevel getConfidenceLevel(double confidence) {
    if (confidence >= 0.90) {
      return ConfidenceLevel.high;
    } else if (confidence >= 0.60) {
      return ConfidenceLevel.medium;
    } else {
      return ConfidenceLevel.low;
    }
  }

  void logPrediction({
    required String stage,
    required String label,
    required double confidence,
  }) {
    final percent = (confidence * 100).toStringAsFixed(2);
    final level = getConfidenceLevel(confidence);

    String status;

    switch (level) {
      case ConfidenceLevel.high:
        status = "HIGH CONFIDENCE";
        break;
      case ConfidenceLevel.medium:
        status = "MEDIUM (AMBIGUOUS)";
        break;
      case ConfidenceLevel.low:
        status = "LOW CONFIDENCE";
        break;
    }

    debugPrint(
      "[$stage] => $label | $percent% | $status",
    );
  }

  Future<List<ModelPrediction>> predict(String imagePath) async {
    if (!_isLoaded || _interpreter == null) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('Failed to decode image.');
    }

    // Make a single square crop only
    final int shortSide = min(decoded.width, decoded.height);

    final int offsetX = (decoded.width - shortSide) ~/ 2;
    final int offsetY = (decoded.height - shortSide) ~/ 2;

    final squareImage = img.copyCrop(
      decoded,
      x: offsetX,
      y: offsetY,
      width: shortSide,
      height: shortSide,
    );

    final scores = _runInference(squareImage);
    final predictions = _findTopPredictions(scores, topK: 2);

    for (final p in predictions) {
      debugPrint("${p.label} : ${(p.confidence * 100).toStringAsFixed(2)}%");
    }

    return predictions;
  }

  List<ModelPrediction> _findTopPredictions(
    List<double> scores, {
    int topK = 2,
  }) {
    final indices = List.generate(scores.length, (i) => i);

    indices.sort(
      (a, b) => scores[b].compareTo(scores[a]),
    );

    return indices.take(topK).map((index) {
      return ModelPrediction(
        label: labelsInOrder[index],
        confidence: scores[index],
        index: index,
      );
    }).toList();
  }

  List<double> _runInference(img.Image image) {
    final inputTensor = _interpreter!.getInputTensor(0);
    final shape = inputTensor.shape;

    final int h = shape[1];
    final int w = shape[2];

    final resized = img.copyResize(
      image,
      width: w,
      height: h,
    );

    final input = List.generate(
      1,
      (_) => List.generate(
        h,
        (y) => List.generate(w, (x) {
          final pixel = resized.getPixel(x, y);

          return [
            pixel.r.toDouble(),
            pixel.g.toDouble(),
            pixel.b.toDouble(),
          ];
        }),
      ),
    );

    final output = [
      List.filled(labelsInOrder.length, 0.0),
    ];

    _interpreter!.run(input, output);

    debugPrint("RAW OUTPUT: ${output[0]}");

    return List<double>.from(output[0]);
  }
}
