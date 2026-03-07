import 'package:cacao_apps/core/ml/cacao_model_service.dart';
import 'package:cacao_apps/core/sync/sync_trigger.dart';

class HomeController {
  final CacaoModelService _modelService;
  final SyncTrigger _syncTrigger;

  HomeController({
    CacaoModelService? modelService,
    SyncTrigger? syncTrigger,
  })  : _modelService = modelService ?? CacaoModelService(),
        _syncTrigger = syncTrigger ?? SyncTrigger();

  Future<void> startBackgroundServices() async {
    await Future.wait([
      _modelService.loadModel(),
      _syncTrigger.start(),
    ]);
  }
}