import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../core/ml/cacao_model_service.dart';
import '../models/cacao_guide.dart';
import '../models/scan_result.dart';

class ScannerController {
  ScannerController({
    required this.cameraController,
    this.languageCode = "en",
  });

  final CameraController cameraController;
  final String languageCode;

  CacaoGuide? _guide;

  /// Load guide JSON once (offline)
  Future<void> loadGuide() async {
    if (_guide != null) return;
    final raw = await rootBundle.loadString('assets/data/cacao_guide.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    _guide = CacaoGuide.fromJson(map);
  }

  CacaoGuide get guide {
    final g = _guide;
    if (g == null) throw StateError("Guide not loaded. Call loadGuide() first.");
    return g;
  }

  /// Main: capture image -> run inference -> return ScanResult
  Future<ScanResult> captureAndPredict() async {
    // Ensure dependencies loaded
    await CacaoModelService().loadModel();
    await loadGuide();

    // 1) Capture
    final XFile shot = await cameraController.takePicture();
    final file = File(shot.path);

    // 2) Predict
    final result = await _predictFile(file);

    return result;
  }

  Future<ScanResult> _predictFile(File file) async {
    final interpreter = CacaoModelService().interpreter;

    final inputTensor = interpreter.getInputTensor(0);
    final outputTensor = interpreter.getOutputTensor(0);

    final inputShape = inputTensor.shape;   // [1, h, w, 3]
    final outputShape = outputTensor.shape; // [1, N]
    final inputType = inputTensor.type;
    final nClasses = outputShape[1];

    if (guide.labelsInOrder.length != nClasses) {
      // Defensive: label count must match output classes
      return const ScanResult(
        rawLabel: "unknown",
        diseaseKey: "unknown",
        severityKey: "unknown",
        confidence: 0.0,
        topK: [],
      );
    }

    final h = inputShape[1];
    final w = inputShape[2];

    // Decode + resize
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const ScanResult(
        rawLabel: "unknown",
        diseaseKey: "unknown",
        severityKey: "unknown",
        confidence: 0.0,
        topK: [],
      );
    }
    final resized = img.copyResize(decoded, width: w, height: h);

    // Build input
    // Assumption: float32 model trained with rescale=1/255.
    // If your model was trained with -1..1 normalization, change normalization below.
    final input = List.generate(
      1,
      (_) => List.generate(
        h,
        (_) => List.generate(w, (_) => List.filled(3, 0.0)),
      ),
    );

   for (int y = 0; y < h; y++) {
  for (int x = 0; x < w; x++) {
    final p = resized.getPixel(x, y);

    final r = p.r;
    final g = p.g;
    final b = p.b;

    if (inputType == TfLiteType.kTfLiteFloat32) {
      input[0][y][x][0] = r / 255.0;
      input[0][y][x][1] = g / 255.0;
      input[0][y][x][2] = b / 255.0;
    } else {
      input[0][y][x][0] = r.toDouble();
      input[0][y][x][1] = g.toDouble();
      input[0][y][x][2] = b.toDouble();
    }
  }
}

    // Output
    final output = List.generate(1, (_) => List.filled(nClasses, 0.0));
    interpreter.run(input, output);

    final probs = output[0];

    // Best + topK
    int bestIdx = 0;
    double best = probs[0];
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > best) {
        best = probs[i];
        bestIdx = i;
      }
    }

    final indexed = List.generate(probs.length, (i) => MapEntry(i, probs[i]));
    indexed.sort((a, b) => b.value.compareTo(a.value));
    final topK = indexed.take(3).map((e) {
      final label = guide.labelsInOrder[e.key];
      return {label: e.value};
    }).toList();

    final rawLabel = guide.labelsInOrder[bestIdx];
    final parsed = _parseLabel(rawLabel);

    final confidence = best;
    final threshold = guide.uncertainThreshold;
    if (confidence < threshold) {
      return ScanResult(
        rawLabel: rawLabel,
        diseaseKey: "unknown",
        severityKey: "unknown",
        confidence: confidence,
        topK: topK,
      );
    }

    return ScanResult(
      rawLabel: rawLabel,
      diseaseKey: parsed.$1,
      severityKey: parsed.$2,
      confidence: confidence,
      topK: topK,
    );
  }

  /// Parses your label style:
  /// - "mealybug_severe" => ("mealybug","severe")
  /// - "black_pod_disease_mild" => ("black_pod_disease","mild")
  /// - "healthy" => ("healthy","default")
  (String, String) _parseLabel(String label) {
    if (label == "healthy") return ("healthy", "default");

    final parts = label.split('_');
    if (parts.length < 2) return ("unknown", "unknown");

    final last = parts.last;
    const severities = {"mild", "moderate", "severe"};
    if (!severities.contains(last)) {
      // No severity suffix
      return (label, "default");
    }

    final diseaseKey = parts.sublist(0, parts.length - 1).join('_');
    return (diseaseKey, last);
  }
}
