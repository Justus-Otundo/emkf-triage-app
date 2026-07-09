import 'package:emkf_triage_app/core/errors/exceptions.dart';
import 'package:emkf_triage_app/core/errors/failures.dart';
import 'package:emkf_triage_app/core/network/network_info.dart';
import 'package:emkf_triage_app/core/utils/result.dart';
import 'package:emkf_triage_app/features/triage/data/datasources/triage_local_datasource.dart';
import 'package:emkf_triage_app/features/triage/data/datasources/triage_remote_datasource.dart';
import 'package:emkf_triage_app/features/triage/data/models/triage_record_model.dart';
import 'package:emkf_triage_app/features/triage/data/repositories/triage_repository_impl.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDatasource extends Mock implements TriageRemoteDatasource {}

class MockLocalDatasource extends Mock implements TriageLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  setUpAll(() {
    registerFallbackValue(TriageRecordModel(
      id: 'fallback',
      patientName: 'fallback',
      conditionDescription: 'fallback',
      priority: 3,
      status: 'pending',
      createdAt: DateTime.now().toIso8601String(),
    ));
    registerFallbackValue(TriageRecord(
      id: 'fallback',
      patientName: 'fallback',
      conditionDescription: 'fallback',
      priority: 3,
    ));
  });
  late MockRemoteDatasource mockRemote;
  late MockLocalDatasource mockLocal;
  late MockNetworkInfo mockNetworkInfo;
  late TriageRepositoryImpl repository;

  final testRecord = TriageRecord(
    id: 'TRI-123-456',
    patientName: 'John Doe',
    conditionDescription: 'Chest pain',
    priority: 1,
  );

  setUp(() {
    mockRemote = MockRemoteDatasource();
    mockLocal = MockLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = TriageRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
      networkInfo: mockNetworkInfo,
    );
  });

  group('submitRecord', () {
    test('should save locally and return synced when online', () async {
      when(() => mockLocal.saveRecord(any())).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.submitRecord(any())).thenAnswer(
        (_) async => {'success': true},
      );
      when(() => mockLocal.markAsSynced(testRecord.id))
          .thenAnswer((_) async {});

      final result = await repository.submitRecord(testRecord);

      expect(result, isA<Success<TriageRecord>>());
      expect((result as Success).data.synced, isTrue);
      verify(() => mockLocal.saveRecord(any())).called(1);
      verify(() => mockRemote.submitRecord(any())).called(1);
      verify(() => mockLocal.markAsSynced(testRecord.id)).called(1);
    });

    test('should save locally but not synced when offline', () async {
      when(() => mockLocal.saveRecord(any())).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.submitRecord(testRecord);

      expect(result, isA<Success<TriageRecord>>());
      expect((result as Success).data.synced, isFalse);
      verify(() => mockLocal.saveRecord(any())).called(1);
      verifyNever(() => mockRemote.submitRecord(any()));
      verifyNever(() => mockLocal.markAsSynced(any()));
    });

    test('should save locally when remote fails while online', () async {
      when(() => mockLocal.saveRecord(any())).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.submitRecord(any())).thenThrow(
        ServerException('Server error'),
      );

      final result = await repository.submitRecord(testRecord);

      expect(result, isA<Success<TriageRecord>>());
      expect((result as Success).data.synced, isFalse);
      verify(() => mockLocal.saveRecord(any())).called(1);
      verify(() => mockRemote.submitRecord(any())).called(1);
      verifyNever(() => mockLocal.markAsSynced(any()));
    });

    test('should return error when local save fails', () async {
      when(() => mockLocal.saveRecord(any())).thenThrow(
        CacheException('Disk full'),
      );

      final result = await repository.submitRecord(testRecord);

      expect(result, isA<Error<TriageRecord>>());
      expect((result as Error).failure, isA<CacheFailure>());
    });
  });

  group('getPendingRecords', () {
    test('should return unsynced records from local datasource', () async {
      final models = [
        TriageRecordModel(
          id: 'TRI-1',
          patientName: 'Patient 1',
          conditionDescription: 'Condition 1',
          priority: 1,
          status: 'pending',
          createdAt: DateTime.now().toIso8601String(),
          synced: false,
        ),
      ];

      when(() => mockLocal.getUnsyncedRecords()).thenAnswer(
        (_) async => models,
      );

      final result = await repository.getPendingRecords();

      expect(result, isA<Success<List<TriageRecord>>>());
      final records = (result as Success).data;
      expect(records.length, 1);
      expect(records.first.id, 'TRI-1');
    });

    test('should return error when local datasource fails', () async {
      when(() => mockLocal.getUnsyncedRecords()).thenThrow(
        CacheException('Box not found'),
      );

      final result = await repository.getPendingRecords();

      expect(result, isA<Error<List<TriageRecord>>>());
    });
  });
}
