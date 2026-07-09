import 'package:emkf_triage_app/core/errors/failures.dart';
import 'package:emkf_triage_app/core/utils/result.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';
import 'package:emkf_triage_app/features/triage/domain/repositories/triage_repository.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_bloc.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_event.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTriageRepository extends Mock implements TriageRepository {}

void main() {
  late MockTriageRepository mockRepository;
  late TriageBloc bloc;

  setUpAll(() {
    registerFallbackValue(TriageRecord(
      id: 'fallback',
      patientName: 'fb',
      conditionDescription: 'fb',
      priority: 3,
    ));
  });

  setUp(() {
    mockRepository = MockTriageRepository();
    bloc = TriageBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('SubmitTriage', () {
    test('should emit [TriageSubmitting, TriageSaved] on successful submission',
        () async {
      final record = TriageRecord(
        id: 'TRI-123-456',
        patientName: 'John Doe',
        conditionDescription: 'Chest pain',
        priority: 1,
        synced: true,
      );

      when(() => mockRepository.submitRecord(any())).thenAnswer(
        (_) async => Success(record),
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TriageSubmitting>(),
          isA<TriageSaved>().having(
            (s) => s.record.synced,
            'synced',
            isTrue,
          ),
        ]),
      );

      bloc.add(const SubmitTriage(
        patientName: 'John Doe',
        conditionDescription: 'Chest pain',
        priority: 1,
      ));
    });

    test('should emit [TriageSubmitting, TriageError] on empty patient name',
        () async {
      final expected = [
        isA<TriageSubmitting>(),
        isA<TriageError>().having(
          (e) => e.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const SubmitTriage(
        patientName: '',
        conditionDescription: 'Chest pain',
        priority: 1,
      ));
    });

    test('should emit [TriageSubmitting, TriageError] on empty description',
        () async {
      final expected = [
        isA<TriageSubmitting>(),
        isA<TriageError>().having(
          (e) => e.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const SubmitTriage(
        patientName: 'John Doe',
        conditionDescription: '',
        priority: 1,
      ));
    });

    test('should emit [TriageSubmitting, TriageError] on invalid priority',
        () async {
      final expected = [
        isA<TriageSubmitting>(),
        isA<TriageError>().having(
          (e) => e.failure,
          'failure',
          isA<ValidationFailure>(),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const SubmitTriage(
        patientName: 'John Doe',
        conditionDescription: 'Chest pain',
        priority: 0,
      ));
    });

    test(
        'should emit [TriageSubmitting, TriageError] when repository fails',
        () async {
      when(() => mockRepository.submitRecord(any())).thenAnswer(
        (_) async => Error(CacheFailure('Failed to save')),
      );

      final expected = [
        isA<TriageSubmitting>(),
        isA<TriageError>().having(
          (e) => e.failure.message,
          'message',
          'Failed to save',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(const SubmitTriage(
        patientName: 'John Doe',
        conditionDescription: 'Chest pain',
        priority: 3,
      ));
    });
  });

  group('ResetTriageForm', () {
    test('should emit TriageInitial', () {
      expectLater(
        bloc.stream,
        emits(isA<TriageInitial>()),
      );

      bloc.add(ResetTriageForm());
    });
  });

  group('LoadPendingRecords', () {
    test('should emit TriageRecordsLoaded with pending records', () async {
      final records = [
        TriageRecord(
          id: 'TRI-111',
          patientName: 'Patient 1',
          conditionDescription: 'Condition 1',
          priority: 1,
        ),
      ];

      when(() => mockRepository.getPendingRecords()).thenAnswer(
        (_) async => Success(records),
      );

      final expected = [
        isA<TriageRecordsLoaded>().having(
          (s) => s.pendingRecords,
          'records',
          hasLength(1),
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));

      bloc.add(LoadPendingRecords());
    });
  });
}
