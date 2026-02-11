import 'package:tflite_flutter/tflite_flutter.dart';

class CacaoModelService {
  static final CacaoModelService _instance = CacaoModelService._internal();
  factory CacaoModelService() => _instance;
  CacaoModelService._internal();

  late Interpreter _interpreter;
  bool _isLoaded = false;

  Future<void> loadModel() async {
    if (_isLoaded) return;

    _interpreter = await Interpreter.fromAsset(
      'models/final_cacao_disease_model1.0.tflite',
      options: InterpreterOptions()..threads = 2,
    );

    _isLoaded = true;
  }

  Interpreter get interpreter => _interpreter;
}
