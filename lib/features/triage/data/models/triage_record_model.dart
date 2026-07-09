import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';
import 'package:emkf_triage_app/core/utils/typedefs.dart';
import 'package:hive/hive.dart';

class TriageRecordModel extends HiveObject {
  final String id;
  final String patientName;
  final String conditionDescription;
  final int priority;
  final String status;
  final String createdAt;
  final bool synced;

  TriageRecordModel({
    required this.id,
    required this.patientName,
    required this.conditionDescription,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.synced = false,
  });

  factory TriageRecordModel.fromDomain(TriageRecord record) {
    return TriageRecordModel(
      id: record.id,
      patientName: record.patientName,
      conditionDescription: record.conditionDescription,
      priority: record.priority,
      status: record.status.name,
      createdAt: record.createdAt.toIso8601String(),
      synced: record.synced,
    );
  }

  factory TriageRecordModel.fromJson(JsonMap json) {
    return TriageRecordModel(
      id: json['id'] as String,
      patientName: json['patientName'] as String,
      conditionDescription: json['conditionDescription'] as String,
      priority: json['priority'] as int,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      synced: json['synced'] as bool? ?? false,
    );
  }

  TriageRecord toDomain() {
    return TriageRecord(
      id: id,
      patientName: patientName,
      conditionDescription: conditionDescription,
      priority: priority,
      status: TriageStatus.values.firstWhere((e) => e.name == status),
      createdAt: DateTime.parse(createdAt),
      synced: synced,
    );
  }

  JsonMap toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'conditionDescription': conditionDescription,
      'priority': priority,
      'status': status,
      'createdAt': createdAt,
      'synced': synced,
    };
  }
}

class TriageRecordModelAdapter extends TypeAdapter<TriageRecordModel> {
  @override
  final int typeId = 0;

  @override
  TriageRecordModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return TriageRecordModel(
      id: fields[0] as String,
      patientName: fields[1] as String,
      conditionDescription: fields[2] as String,
      priority: fields[3] as int,
      status: fields[4] as String,
      createdAt: fields[5] as String,
      synced: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, TriageRecordModel obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.patientName);
    writer.writeByte(2);
    writer.write(obj.conditionDescription);
    writer.writeByte(3);
    writer.write(obj.priority);
    writer.writeByte(4);
    writer.write(obj.status);
    writer.writeByte(5);
    writer.write(obj.createdAt);
    writer.writeByte(6);
    writer.write(obj.synced);
  }
}
