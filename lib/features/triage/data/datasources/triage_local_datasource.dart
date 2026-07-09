import 'package:emkf_triage_app/core/constants/app_constants.dart';
import 'package:emkf_triage_app/core/errors/exceptions.dart';
import 'package:emkf_triage_app/features/triage/data/models/triage_record_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class TriageLocalDatasource {
  Future<void> saveRecord(TriageRecordModel record);
  Future<List<TriageRecordModel>> getUnsyncedRecords();
  Future<List<TriageRecordModel>> getAllRecords();
  Future<void> markAsSynced(String recordId);
  Future<void> deleteRecord(String recordId);
  Future<void> clearAll();
}

class TriageLocalDatasourceImpl implements TriageLocalDatasource {
  late Box<TriageRecordModel> _box;

  TriageLocalDatasourceImpl() {
    _box = Hive.box<TriageRecordModel>(AppConstants.triageBoxName);
  }

  @override
  Future<void> saveRecord(TriageRecordModel record) async {
    try {
      await _box.put(record.id, record);
    } catch (e) {
      throw CacheException('Failed to save record locally: $e');
    }
  }

  @override
  Future<List<TriageRecordModel>> getUnsyncedRecords() async {
    try {
      return _box.values.where((r) => !r.synced).toList();
    } catch (e) {
      throw CacheException('Failed to fetch unsynced records: $e');
    }
  }

  @override
  Future<List<TriageRecordModel>> getAllRecords() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to fetch records: $e');
    }
  }

  @override
  Future<void> markAsSynced(String recordId) async {
    try {
      final record = _box.get(recordId);
      if (record != null) {
        final updated = TriageRecordModel(
          id: record.id,
          patientName: record.patientName,
          conditionDescription: record.conditionDescription,
          priority: record.priority,
          status: record.status,
          createdAt: record.createdAt,
          synced: true,
        );
        await _box.put(recordId, updated);
      }
    } catch (e) {
      throw CacheException('Failed to mark record as synced: $e');
    }
  }

  @override
  Future<void> deleteRecord(String recordId) async {
    try {
      await _box.delete(recordId);
    } catch (e) {
      throw CacheException('Failed to delete record: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheException('Failed to clear records: $e');
    }
  }
}
