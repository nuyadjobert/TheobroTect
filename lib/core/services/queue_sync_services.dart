import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../db/sync_queue_reporitory.dart';
import '../model/sync_queue.model.dart';

class QueueSyncService {
  final Dio dio;
  final SyncQueueRepository queueRepository;

  QueueSyncService({
    required this.dio,
    required this.queueRepository,
  });

  Future<bool> syncPendingQueue() async {
    try {
      final jobs = await queueRepository.getPendingJobs();

      if (jobs.isEmpty) {
        debugPrint("No pending sync jobs.");
        return true;
      }

      for (final job in jobs) {
        final success = await _processJob(job);

        if (success) {
          await queueRepository.delete(job.id);
        } else {
          await queueRepository.incrementRetry(job.id);
        }
      }

      return true;
    } catch (e) {
      debugPrint("Queue Sync Error: $e");
      return false;
    }
  }

  Future<bool> _processJob(SyncQueue job) async {
    switch (job.tableName) {
      case "users":
        return _syncUser(job);


      default:
        debugPrint("Unknown queue type.");
        return false;
    }
  }

  Future<bool> _syncUser(SyncQueue job) async {
    try {
      await dio.put(
        "/api/theobrotect/users/${job.recordId}",
        data: job.payload,
      );

      return true;
    } on DioException {
      return false;
    }
  }

}
