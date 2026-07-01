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
      'assets/models/mobilenetv3large_retrain_V4.tflite',
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

    final crops = _createCrops(decoded);

    // Full image prediction
    final fullScores = _runInference(crops.first);
    final singlePrediction = _findBestPrediction(fullScores);

    debugPrint("========== INFERENCE START ==========");

    logPrediction(
      stage: "FULL IMAGE",
      label: singlePrediction.label,
      confidence: singlePrediction.confidence,
    );

    final level = getConfidenceLevel(
      singlePrediction.confidence,
    );

    if (level == ConfidenceLevel.high) {
      debugPrint(
        "DECISION => HIGH CONFIDENCE, SKIP MULTI-CROP",
      );

      debugPrint(
        "========== INFERENCE END ==========",
      );

      return [singlePrediction];
    }

    if (level == ConfidenceLevel.medium) {
      debugPrint(
        "DECISION => MEDIUM CONFIDENCE",
      );

      debugPrint(
        "ACTION => MULTI-CROP INFERENCE",
      );
    } else {
      debugPrint(
        "DECISION => LOW CONFIDENCE",
      );

      debugPrint(
        "ACTION => MULTI-CROP INFERENCE",
      );
    }

    return _runMultiCropInference(crops);
  }

  List<img.Image> _createCrops(img.Image decoded) {
    final int shortSide = min(decoded.width, decoded.height);

    final int offsetX = (decoded.width - shortSide) ~/ 2;

    final int offsetY = (decoded.height - shortSide) ~/ 2;

    final img.Image fullCrop = img.copyCrop(
      decoded,
      x: offsetX,
      y: offsetY,
      width: shortSide,
      height: shortSide,
    );

    final img.Image centerCrop = img.copyCrop(
      fullCrop,
      x: shortSide ~/ 4,
      y: shortSide ~/ 4,
      width: shortSide ~/ 2,
      height: shortSide ~/ 2,
    );

    final img.Image leftCrop = img.copyCrop(
      fullCrop,
      x: 0,
      y: 0,
      width: shortSide ~/ 2,
      height: shortSide,
    );

    final img.Image rightCrop = img.copyCrop(
      fullCrop,
      x: shortSide ~/ 2,
      y: 0,
      width: shortSide ~/ 2,
      height: shortSide,
    );

    return [
      fullCrop,
      centerCrop,
      leftCrop,
      rightCrop,
    ];
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

  List<ModelPrediction> _findPrimaryAndSecondaryDisease(
    List<ModelPrediction> cropPredictions,
  ) {
    final Map<String, ModelPrediction> strongestPerDisease = {};

    for (final prediction in cropPredictions) {
      final family = getDiseaseFamily(
        prediction.label,
      );

      final existing = strongestPerDisease[family];

      if (existing == null || prediction.confidence > existing.confidence) {
        strongestPerDisease[family] = prediction;
      }
    }

    final diseases = strongestPerDisease.values.toList();

    diseases.sort(
      (a, b) => b.confidence.compareTo(
        a.confidence,
      ),
    );

    final primary = diseases.first;

    ModelPrediction? secondary;

    if (diseases.length > 1) {
      secondary = diseases[1];
    }

    debugPrint("");
    debugPrint(
      "===== FINAL DECISION =====",
    );

    debugPrint(
      "PRIMARY DISEASE => "
      "${primary.label} "
      "${(primary.confidence * 100).toStringAsFixed(2)}%",
    );

    if (secondary != null) {
      debugPrint(
        "SECONDARY DISEASE => "
        "${secondary.label} "
        "${(secondary.confidence * 100).toStringAsFixed(2)}%",
      );
    }

    debugPrint(
      "========== INFERENCE END ==========",
    );

    return secondary == null ? [primary] : [primary, secondary];
  }

  Future<List<ModelPrediction>> _runMultiCropInference(
    List<img.Image> crops,
  ) async {
    final cropNames = [
      'FULL CROP',
      'CENTER CROP',
      'LEFT CROP',
      'RIGHT CROP',
    ];

    final cropPredictions = <ModelPrediction>[];

    for (int i = 0; i < crops.length; i++) {
      final scores = _runInference(crops[i]);

      // 1. Find the absolute winner for this crop
      final primaryPrediction = _findBestPrediction(scores);
      cropPredictions.add(primaryPrediction);

      // 2. 👉 NEW: Also find the runner-up for this crop if it has decent confidence
      final sortedIndices = List.generate(scores.length, (idx) => idx)
        ..sort((a, b) => scores[b].compareTo(scores[a]));

      int runnerUpIdx = sortedIndices[1];
      double runnerUpScore = scores[runnerUpIdx];

      // If the second-highest disease has a confidence over 15%, count it!
      if (runnerUpScore > 0.15) {
        cropPredictions.add(ModelPrediction(
          label: labelsInOrder[runnerUpIdx],
          confidence: runnerUpScore,
          index: runnerUpIdx,
        ));
      }

      logPrediction(
        stage: cropNames[i],
        label: primaryPrediction.label,
        confidence: primaryPrediction.confidence,
      );
    }

    return _findPrimaryAndSecondaryDisease(
      cropPredictions,
    );
  }

  ModelPrediction _findBestPrediction(
    List<double> scores,
  ) {
    int bestIdx = 0;
    double bestScore = scores[0];

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > bestScore) {
        bestScore = scores[i];
        bestIdx = i;
      }
    }

    return ModelPrediction(
      label: labelsInOrder[bestIdx],
      confidence: bestScore,
      index: bestIdx,
    );
  }
}
