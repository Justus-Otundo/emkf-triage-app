import 'package:flutter/material.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';

class StatusSelector extends StatelessWidget {
  final TriageStatus value;
  final ValueChanged<TriageStatus?> onChanged;

  const StatusSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TriageStatus>(
      segments: const [
        ButtonSegment(
          value: TriageStatus.pending,
          label: Text('Pending'),
          icon: Icon(Icons.hourglass_empty),
        ),
        ButtonSegment(
          value: TriageStatus.inTransit,
          label: Text('In-Transit'),
          icon: Icon(Icons.local_hospital),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selected) {
        if (selected.isNotEmpty) {
          onChanged(selected.first);
        }
      },
    );
  }
}
