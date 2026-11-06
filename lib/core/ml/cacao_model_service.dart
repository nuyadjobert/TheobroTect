import 'dart:io';
import 'dart:math';
import 'dart:ui'; 
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';

import '../model/multitask.dart';

enum ConfidenceLevel {
  low,
  medium,
  high,
}

class CacaoModelService {
  static final CacaoModelService _instance = CacaoModelService._internal();
  factory CacaoModelService() => _instance;
  CacaoModelService._internal();

  Interpreter? _interpreter;
  bool _isLoaded = false;

  static const diseaseLabels = [
    "black_pod_disease",
    "cacao_pod_borer",
    "mealybug",
    "healthy",
    "non_cacao",
    "unsupported_disease",
  ];

  static const severityLabels = [
    "none",
    "mild",
    "moderate",
    "severe",
  ];
  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    if (_isLoaded) return;

    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/2.6.tflite',
        options: InterpreterOptions()..threads = Platform.numberOfProcessors,
      );
      _isLoaded = true;
    } catch (e) {
      rethrow;
    }
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

  Future<List<MultiTaskPrediction>> predict(
    String imagePath, {
    Rect? cropRect,
  }) async {
    if (!_isLoaded || _interpreter == null) {
      throw StateError('Model not loaded. Call loadModel() first.');
    }

    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw Exception('Failed to decode image.');
    }

    img.Image targetImage;

    if (cropRect != null) {
      final int cropX =
          (cropRect.left * decoded.width).round().clamp(0, decoded.width);
      final int cropY =
          (cropRect.top * decoded.height).round().clamp(0, decoded.height);
      final int cropW = (cropRect.width * decoded.width)
          .round()
          .clamp(1, decoded.width - cropX);
      final int cropH = (cropRect.height * decoded.height)
          .round()
          .clamp(1, decoded.height - cropY);

      targetImage = img.copyCrop(
        decoded,
        x: cropX,
        y: cropY,
        width: cropW,
        height: cropH,
      );
    } else {
      final int shortSide = min(decoded.width, decoded.height);
      final int offsetX = (decoded.width - shortSide) ~/ 2;
      final int offsetY = (decoded.height - shortSide) ~/ 2;

      targetImage = img.copyCrop(
        decoded,
        x: offsetX,
        y: offsetY,
        width: shortSide,
        height: shortSide,
      );
    }

    final results = _runInference(targetImage);
    final diseaseScores = results['disease']!;
    final severityScores = results['severity']!;

    int bestDiseaseIdx = 0;
    double maxDiseaseConf = 0.0;
    for (int i = 0; i < diseaseScores.length; i++) {
      if (diseaseScores[i] > maxDiseaseConf) {
        maxDiseaseConf = diseaseScores[i];
        bestDiseaseIdx = i;
      }
    }

    int bestSeverityIdx = 0;
    double maxSeverityConf = 0.0;
    for (int i = 0; i < severityScores.length; i++) {
      if (severityScores[i] > maxSeverityConf) {
        maxSeverityConf = severityScores[i];
        bestSeverityIdx = i;
      }
    }

    final prediction = MultiTaskPrediction(
      diseaseLabel: diseaseLabels[bestDiseaseIdx],
      severityLabel: severityLabels[bestSeverityIdx],
      diseaseConfidence: maxDiseaseConf,
      severityConfidence: maxSeverityConf,
    );

    return [prediction];
  }

  Map<String, List<double>> _runInference(img.Image image) {
    final inputTensor = _interpreter!.getInputTensor(0);
    final shape = inputTensor.shape; 

    final int h = shape[1];
    final int w = shape[2];

    final resized = img.copyResize(image, width: w, height: h);

    final floatInput = Float32List(1 * h * w * 3);
    int bufferIndex = 0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = resized.getPixel(x, y);
        floatInput[bufferIndex++] = pixel.r.toDouble();
        floatInput[bufferIndex++] = pixel.g.toDouble();
        floatInput[bufferIndex++] = pixel.b.toDouble();
      }
    }

    final input = floatInput.reshape([1, h, w, 3]);

    int out0Length = _interpreter!.getOutputTensor(0).shape[1];

    int diseaseTensorIndex = (out0Length == diseaseLabels.length) ? 0 : 1;
    int severityTensorIndex = (diseaseTensorIndex == 0) ? 1 : 0;

    final diseaseOutput = [List.filled(diseaseLabels.length, 0.0)];
    final severityOutput = [List.filled(severityLabels.length, 0.0)];

    Map<int, Object> outputs = {
      diseaseTensorIndex: diseaseOutput,
      severityTensorIndex: severityOutput,
    };

    _interpreter!.runForMultipleInputs([input], outputs);

    return {
      'disease': List<double>.from((outputs[diseaseTensorIndex] as List)[0]),
      'severity': List<double>.from((outputs[severityTensorIndex] as List)[0]),
    };
  }
}