// File: lib/core/database/repositories/cacao_guide_repository.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import './database_helper.dart';

class CacaoGuideRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> syncCacaoGuide(List<dynamic> backendJsonPayload) async {
    final database = await _dbHelper.db;
    final batch = database.batch();

    try {
      for (var diseaseMap in backendJsonPayload) {
        final diseaseId = diseaseMap['disease_id'];

        batch.insert(
          'guide_diseases',
          {
            'id': diseaseId,
            'disease_key': diseaseMap['disease_key'],
            'display_name': json.encode(diseaseMap['display_name']),
            'description': json.encode(diseaseMap['description']),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final severities = diseaseMap['severities'] as List<dynamic>? ?? [];
        for (var severityMap in severities) {
          final severityId = severityMap['severity_id'];

          batch.insert(
            'guide_disease_severities',
            {
              'id': severityId,
              'disease_id': diseaseId,
              'severity_level': severityMap['level'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          final monitoringPlan = severityMap['monitoring_plan'];
          if (monitoringPlan != null) {
            batch.insert(
              'guide_monitoring_plans',
              {
                'disease_severity_id': severityId,
                'rescan_after_days': monitoringPlan['rescan_after_days'],
                'preferred_time_hour': monitoringPlan['preferred_time_hour'],
                'message': json.encode(monitoringPlan['message']),
                'checklist': json.encode(monitoringPlan['checklist']),
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          final recommendations = severityMap['recommendations'] as List<dynamic>? ?? [];
          for (var recMap in recommendations) {
            batch.insert(
              'guide_recommendations',
              {
                'disease_severity_id': severityId,
                'category_key': recMap['category'],
                'content': json.encode(recMap['content']),
                'sort_order': recMap['sort_order'],
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
      await batch.commit(noResult: true);
      debugPrint('Cacao Guide Sync Completed Successfully.');
    } catch (e) {
      debugPrint('Error syncing cacao guide: $e');
      rethrow;
    }
  }
}