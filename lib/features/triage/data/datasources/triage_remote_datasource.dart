import 'package:emkf_triage_app/core/constants/app_constants.dart';
import 'package:emkf_triage_app/core/errors/exceptions.dart';
import 'package:emkf_triage_app/core/network/api_client.dart';
import 'package:emkf_triage_app/features/triage/data/models/triage_record_model.dart';
import 'package:emkf_triage_app/core/utils/typedefs.dart';

abstract class TriageRemoteDatasource {
  Future<JsonMap> submitRecord(TriageRecordModel record);
}

class TriageRemoteDatasourceImpl implements TriageRemoteDatasource {
  final ApiClient apiClient;

  TriageRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<JsonMap> submitRecord(TriageRecordModel record) async {
    try {
      final response = await apiClient.post(
        AppConstants.triageEndpoint,
        data: record.toJson(),
      );
      return response.data as JsonMap;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to submit record: $e');
    }
  }
}

class TriageRemoteDatasourceMock implements TriageRemoteDatasource {
  @override
  Future<JsonMap> submitRecord(TriageRecordModel record) async {
    await Future.delayed(AppConstants.mockDelay);

    return {
      'success': true,
      'id': record.id,
      'message': 'Triage record submitted successfully',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
