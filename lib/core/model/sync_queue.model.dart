import 'dart:convert';

class SyncQueue {
  final int id;
  final String tableName;
  final String recordId;
  final String action;
  final Map<String, dynamic> payload;
  final int status;
  final int retryCount;
  final String createdAt;

  SyncQueue({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.action,
    required this.payload,
    required this.status,
    required this.retryCount,
    required this.createdAt,
  });

  factory SyncQueue.fromMap(Map<String, dynamic> map) {
    return SyncQueue(
      id: map['id'] as int,
      tableName: map['table_name'] as String,
      recordId: map['record_id'] as String,
      action: map['action'] as String,
      payload: jsonDecode(map['payload'] as String),
      status: map['status'] as int,
      retryCount: map['retry_count'] as int,
      createdAt: map['created_at'] as String,
    );
  }
}