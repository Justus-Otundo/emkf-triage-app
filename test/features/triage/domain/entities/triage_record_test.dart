import 'package:flutter_test/flutter_test.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';

void main() {
  group('TriageRecord', () {
    final record = TriageRecord(
      id: 'TRI-123-456',
      patientName: 'John Doe',
      conditionDescription: 'Chest pain and difficulty breathing',
      priority: 1,
      status: TriageStatus.pending,
    );

    test('should set createdAt to now when not provided', () {
      final now = DateTime.now();
      final r = TriageRecord(
        id: 'TRI-789-012',
        patientName: 'Jane Smith',
        conditionDescription: 'Fractured leg',
        priority: 3,
      );

      expect(r.createdAt.isAfter(now.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(r.createdAt.isBefore(now.add(const Duration(seconds: 1))),
          isTrue);
    });

    test('should detect critical cases (priority <= 2)', () {
      expect(
        TriageRecord(
          id: '1', patientName: 'A', conditionDescription: 'B', priority: 1,
        ).isCritical,
        isTrue,
      );
      expect(
        TriageRecord(
          id: '2', patientName: 'A', conditionDescription: 'B', priority: 2,
        ).isCritical,
        isTrue,
      );
      expect(
        TriageRecord(
          id: '3', patientName: 'A', conditionDescription: 'B', priority: 3,
        ).isCritical,
        isFalse,
      );
      expect(
        TriageRecord(
          id: '4', patientName: 'A', conditionDescription: 'B', priority: 5,
        ).isCritical,
        isFalse,
      );
    });

    test('copyWith should update only provided fields', () {
      final updated = record.copyWith(
        patientName: 'John Updated',
        priority: 2,
        synced: true,
      );

      expect(updated.id, record.id);
      expect(updated.patientName, 'John Updated');
      expect(updated.conditionDescription, record.conditionDescription);
      expect(updated.priority, 2);
      expect(updated.status, record.status);
      expect(updated.synced, isTrue);
    });

    test('should support value equality', () {
      final copy = TriageRecord(
        id: record.id,
        patientName: record.patientName,
        conditionDescription: record.conditionDescription,
        priority: record.priority,
        status: record.status,
        createdAt: record.createdAt,
        synced: record.synced,
      );

      expect(record, equals(copy));
    });

    test('should have different equality for different records', () {
      final different = TriageRecord(
        id: 'TRI-999-888',
        patientName: record.patientName,
        conditionDescription: record.conditionDescription,
        priority: record.priority,
      );

      expect(record, isNot(equals(different)));
    });

    test('default status should be pending', () {
      final r = TriageRecord(
        id: 'TRI-111-222',
        patientName: 'Test',
        conditionDescription: 'Test',
        priority: 3,
      );

      expect(r.status, TriageStatus.pending);
    });

    test('default synced should be false', () {
      final r = TriageRecord(
        id: 'TRI-333-444',
        patientName: 'Test',
        conditionDescription: 'Test',
        priority: 4,
      );

      expect(r.synced, isFalse);
    });
  });
}
