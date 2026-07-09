import 'package:emkf_triage_app/core/errors/failures.dart';
import 'package:emkf_triage_app/core/network/network_info.dart';
import 'package:emkf_triage_app/core/utils/result.dart';
import 'package:emkf_triage_app/features/triage/data/datasources/triage_local_datasource.dart';
import 'package:emkf_triage_app/features/triage/data/datasources/triage_remote_datasource.dart';
import 'package:emkf_triage_app/features/triage/data/models/triage_record_model.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';
import 'package:emkf_triage_app/features/triage/domain/repositories/triage_repository.dart';

class TriageRepositoryImpl implements TriageRepository {
  final TriageRemoteDatasource remoteDatasource;
  final TriageLocalDatasource localDatasource;
  final NetworkInfo networkInfo;

  TriageRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.networkInfo,
  });

  @override
  Future<Result<TriageRecord>> submitRecord(TriageRecord record) async {
    try {
      final model = TriageRecordModel.fromDomain(record);
      await localDatasource.saveRecord(model);

      if (await networkInfo.isConnected) {
        try {
          await remoteDatasource.submitRecord(model);
          await localDatasource.markAsSynced(record.id);
          return Success(record.copyWith(synced: true));
        } catch (_) {
          return Success(record);
        }
      }

      return Success(record);
    } catch (e) {
      return Error(CacheFailure('Failed to save triage record: $e'));
    }
  }

  @override
  Future<Result<List<TriageRecord>>> getPendingRecords() async {
    try {
      final models = await localDatasource.getUnsyncedRecords();
      final records = models.map((m) => m.toDomain()).toList();
      return Success(records);
    } catch (e) {
      return Error(CacheFailure('Failed to fetch pending records: $e'));
    }
  }

  @override
  Future<Result<void>> markAsSynced(String recordId) async {
    try {
      await localDatasource.markAsSynced(recordId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Failed to mark record as synced: $e'));
    }
  }

  @override
  Future<Result<void>> deleteRecord(String recordId) async {
    try {
      await localDatasource.deleteRecord(recordId);
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure('Failed to delete record: $e'));
    }
  }
}
