import 'package:equatable/equatable.dart';

enum TriageStatus { pending, inTransit }

class TriageRecord extends Equatable {
  final String id;
  final String patientName;
  final String conditionDescription;
  final int priority;
  final TriageStatus status;
  final DateTime createdAt;
  final bool synced;

  TriageRecord({
    required this.id,
    required this.patientName,
    required this.conditionDescription,
    required this.priority,
    this.status = TriageStatus.pending,
    DateTime? createdAt,
    this.synced = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isCritical => priority <= 2;

  TriageRecord copyWith({
    String? id,
    String? patientName,
    String? conditionDescription,
    int? priority,
    TriageStatus? status,
    DateTime? createdAt,
    bool? synced,
  }) {
    return TriageRecord(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      conditionDescription: conditionDescription ?? this.conditionDescription,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientName,
        conditionDescription,
        priority,
        status,
        createdAt,
        synced,
      ];
}
