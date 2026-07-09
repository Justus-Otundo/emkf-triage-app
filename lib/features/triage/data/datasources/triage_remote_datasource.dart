import 'dart:math';
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
  final Random _random = Random();

  /// Probability of simulated network failure (0.0–1.0).
  /// Set to 0 for consistent demos, >0 to prove sync queue retry logic.
  final double failureProbability;

  TriageRemoteDatasourceMock({this.failureProbability = AppConstants.mockFailureProbability});

  @override
  Future<JsonMap> submitRecord(TriageRecordModel record) async {
    await Future.delayed(AppConstants.mockDelay);

    if (failureProbability > 0 && _random.nextDouble() < failureProbability) {
      throw ServerException('Simulated network failure — record queued for retry');
    }

    return {
      'success': true,
      'id': record.id,
      'message': 'Triage record submitted successfully',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
