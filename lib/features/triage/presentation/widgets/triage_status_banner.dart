import 'package:flutter/material.dart';
import 'package:emkf_triage_app/core/theme/triage_colors.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';

class TriageStatusBanner extends StatelessWidget {
  final TriageRecord record;

  const TriageStatusBanner({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    if (!record.isCritical) return const SizedBox.shrink();

    final color = record.priority == 1
        ? TriageColors.criticalRed
        : TriageColors.criticalOrange;

    final label = record.priority == 1
        ? 'CRITICAL — Immediate attention required'
        : 'EMERGENCY — High priority case';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
