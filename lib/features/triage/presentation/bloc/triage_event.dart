import 'package:equatable/equatable.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';

sealed class TriageEvent extends Equatable {
  const TriageEvent();

  @override
  List<Object?> get props => [];
}

class SubmitTriage extends TriageEvent {
  final String patientName;
  final String conditionDescription;
  final int priority;
  final TriageStatus status;

  const SubmitTriage({
    required this.patientName,
    required this.conditionDescription,
    required this.priority,
    this.status = TriageStatus.pending,
  });

  @override
  List<Object?> get props => [
        patientName,
        conditionDescription,
        priority,
        status,
      ];
}

class ResetTriageForm extends TriageEvent {}

class LoadPendingRecords extends TriageEvent {}
