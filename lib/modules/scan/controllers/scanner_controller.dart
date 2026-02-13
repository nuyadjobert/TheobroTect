import 'package:cacao_apps/core/ml/cacao_model_service.dart';
import 'package:cacao_apps/modules/scan/model/scan_result_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';


class ScannerController extends ChangeNotifier {
  
  CameraController? _camera;
  List<CameraDescription>? _cameras;

  bool _isPermissionGranted = false;
  bool _isFlashOn = false;
  bool _isAnalyzing = false;

CameraController? get camera => _camera;
CameraController? get cameraController => _camera;
  bool get isPermissionGranted => _isPermissionGranted;
  bool get isFlashOn => _isFlashOn;
  bool get isAnalyzing => _isAnalyzing;

  bool get isReady =>
      _isPermissionGranted && _camera != null && _camera!.value.isInitialized;

  Future<void> init() async {
    await CacaoModelService().loadModel();
    await _setupCamera();
  }

  Future<void> _setupCamera() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      _isPermissionGranted = false;
      notifyListeners();
      return;
    }

    _isPermissionGranted = true;
    notifyListeners();

    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      _isPermissionGranted = false;
      notifyListeners();
      return;
    }

    _camera = CameraController(
      _cameras![0],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _camera!.initialize();
    notifyListeners();
  }

  Future<void> toggleFlash() async {
    if (_camera == null) return;

    if (_isFlashOn) {
      await _camera!.setFlashMode(FlashMode.off);
    } else {
      await _camera!.setFlashMode(FlashMode.torch);
    }

    _isFlashOn = !_isFlashOn;
    notifyListeners();
  }
Future<ScanResultModel?> captureAndAnalyze() async {
  if (!isReady) return null;
  if (_isAnalyzing) return null;

  HapticFeedback.heavyImpact();

  _isAnalyzing = true;
  notifyListeners();

  try {
    final XFile photo = await _camera!.takePicture();
    final imagePath = photo.path;

    final pred = await CacaoModelService().predict(imagePath);
    final parsed = _parseLabel(pred.label);

    return ScanResultModel(
      imagePath: imagePath,
      diseaseName: _toDisplayName(parsed.diseaseKey),
      confidence: pred.confidence,
      severity: _capitalize(parsed.severityKey),
    );
  } catch (e) {
    return null;
  } finally {
    _isAnalyzing = false;
    notifyListeners();
  }
}

// --- helpers ---

_ParsedLabel _parseLabel(String label) {
  if (label == 'healthy') {
    return const _ParsedLabel(diseaseKey: 'healthy', severityKey: 'default');
  }
  final idx = label.lastIndexOf('_');
  final diseaseKey = label.substring(0, idx);     
  final severityKey = label.substring(idx + 1);   
  return _ParsedLabel(diseaseKey: diseaseKey, severityKey: severityKey);
}

String _toDisplayName(String diseaseKey) {
  switch (diseaseKey) {
    case 'black_pod_disease':
      return 'Black Pod Disease';
    case 'cacao_pod_borer':
      return 'Cacao Pod Borer';
    case 'mealybug':
      return 'Mealybug';
    case 'healthy':
      return 'Healthy';
    default:
      return diseaseKey;
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';


  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }
}

class _ParsedLabel {
  final String diseaseKey;
  final String severityKey;
  const _ParsedLabel({required this.diseaseKey, required this.severityKey});
}
