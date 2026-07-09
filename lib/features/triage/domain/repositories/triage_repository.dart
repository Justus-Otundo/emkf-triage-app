import 'package:emkf_triage_app/core/utils/result.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';

abstract class TriageRepository {
  Future<Result<TriageRecord>> submitRecord(TriageRecord record);
  Future<Result<List<TriageRecord>>> getPendingRecords();
  Future<Result<void>> markAsSynced(String recordId);
  Future<Result<void>> deleteRecord(String recordId);
}
