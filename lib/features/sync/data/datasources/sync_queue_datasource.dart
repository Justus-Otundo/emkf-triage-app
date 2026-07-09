import 'dart:async';
import 'package:emkf_triage_app/core/constants/app_constants.dart';
import 'package:emkf_triage_app/core/errors/exceptions.dart';
import 'package:emkf_triage_app/features/triage/data/models/triage_record_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class SyncQueueDatasource {
  Future<void> enqueue(TriageRecordModel record);
  Future<List<TriageRecordModel>> getPending();
  Future<void> dequeue(String recordId);
  Future<int> pendingCount();
  Stream<int> get pendingCountStream;
}

class SyncQueueDatasourceImpl implements SyncQueueDatasource {
  late final Box<TriageRecordModel> _box;

  SyncQueueDatasourceImpl() {
    _box = Hive.box<TriageRecordModel>(AppConstants.syncBoxName);
  }

  @override
  Future<void> enqueue(TriageRecordModel record) async {
    try {
      await _box.put(record.id, record);
    } catch (e) {
      throw CacheException('Failed to enqueue sync record: $e');
    }
  }

  @override
  Future<List<TriageRecordModel>> getPending() async {
    try {
      return _box.values.where((r) => !r.synced).toList();
    } catch (e) {
      throw CacheException('Failed to get pending sync records: $e');
    }
  }

  @override
  Future<void> dequeue(String recordId) async {
    try {
      await _box.delete(recordId);
    } catch (e) {
      throw CacheException('Failed to dequeue sync record: $e');
    }
  }

  @override
  Future<int> pendingCount() async {
    try {
      return _box.values.where((r) => !r.synced).length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Stream<int> get pendingCountStream {
    return _box.watch().map((_) {
      try {
        return _box.values.where((r) => !r.synced).length;
      } catch (_) {
        return 0;
      }
    });
  }
}
