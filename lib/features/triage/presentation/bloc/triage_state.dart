import 'package:equatable/equatable.dart';
import 'package:emkf_triage_app/core/errors/failures.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';

sealed class TriageState extends Equatable {
  const TriageState();

  @override
  List<Object?> get props => [];
}

class TriageInitial extends TriageState {}

class TriageSubmitting extends TriageState {}

class TriageSaved extends TriageState {
  final TriageRecord record;
  final bool syncedToServer;

  const TriageSaved({required this.record, this.syncedToServer = false});

  @override
  List<Object?> get props => [record, syncedToServer];
}

class TriageError extends TriageState {
  final Failure failure;

  const TriageError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class TriageRecordsLoaded extends TriageState {
  final List<TriageRecord> pendingRecords;

  const TriageRecordsLoaded(this.pendingRecords);

  @override
  List<Object?> get props => [pendingRecords];
}
