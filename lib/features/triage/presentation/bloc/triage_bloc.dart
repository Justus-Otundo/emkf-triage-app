import 'package:emkf_triage_app/core/errors/failures.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';
import 'package:emkf_triage_app/features/triage/domain/repositories/triage_repository.dart';
import 'package:emkf_triage_app/core/utils/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'triage_event.dart';
import 'triage_state.dart';

class TriageBloc extends Bloc<TriageEvent, TriageState> {
  final TriageRepository _repository;

  TriageBloc({required TriageRepository repository})
      : _repository = repository,
        super(TriageInitial()) {
    on<SubmitTriage>(_onSubmitTriage);
    on<ResetTriageForm>(_onResetForm);
    on<LoadPendingRecords>(_onLoadPending);
  }

  Future<void> _onSubmitTriage(
    SubmitTriage event,
    Emitter<TriageState> emit,
  ) async {
    emit(TriageSubmitting());

    final validationError = _validate(event);
    if (validationError != null) {
      emit(TriageError(validationError));
      return;
    }

    final record = TriageRecord(
      id: _generateId(),
      patientName: event.patientName.trim(),
      conditionDescription: event.conditionDescription.trim(),
      priority: event.priority,
      status: event.status,
    );

    final result = await _repository.submitRecord(record);

    switch (result) {
      case Success<TriageRecord>():
        emit(TriageSaved(
          record: result.data,
          syncedToServer: result.data.synced,
        ));
      case Error<TriageRecord>():
        emit(TriageError(result.failure));
    }
  }

  void _onResetForm(ResetTriageForm event, Emitter<TriageState> emit) {
    emit(TriageInitial());
  }

  Future<void> _onLoadPending(
    LoadPendingRecords event,
    Emitter<TriageState> emit,
  ) async {
    final result = await _repository.getPendingRecords();
    switch (result) {
      case Success<List<TriageRecord>>():
        emit(TriageRecordsLoaded(result.data));
      case Error<List<TriageRecord>>():
        emit(TriageError(result.failure));
    }
  }

  Failure? _validate(SubmitTriage event) {
    if (event.patientName.trim().isEmpty) {
      return const ValidationFailure('Patient name is required');
    }
    if (event.conditionDescription.trim().isEmpty) {
      return const ValidationFailure('Condition description is required');
    }
    if (event.priority < 1 || event.priority > 5) {
      return const ValidationFailure('Priority must be between 1 and 5');
    }
    return null;
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'TRI-$timestamp-$random';
  }
}
