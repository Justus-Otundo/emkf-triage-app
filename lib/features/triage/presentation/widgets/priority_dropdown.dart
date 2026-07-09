import 'package:flutter/material.dart';
import 'package:emkf_triage_app/core/theme/triage_colors.dart';

class PriorityDropdown extends StatelessWidget {
  final int? value;
  final String? errorText;
  final ValueChanged<int?> onChanged;

  const PriorityDropdown({
    super.key,
    required this.value,
    this.errorText,
    required this.onChanged,
  });

  static const _priorityLabels = {
    1: '1 — Critical (Life-threatening)',
    2: '2 — Emergency (High risk)',
    3: '3 — Urgent (Moderate)',
    4: '4 — Semi-urgent (Stable)',
    5: '5 — Non-urgent (Minor)',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          // ignore: deprecated_member_use
          value: value,
          decoration: InputDecoration(
            labelText: 'Priority Level',
            prefixIcon: const Icon(Icons.warning_amber_rounded),
            errorText: errorText,
          ),
          items: List.generate(5, (i) {
            final priority = i + 1;
            final color = TriageColors.priorityColor(priority);
            return DropdownMenuItem(
              value: priority,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _priorityLabels[priority]!,
                      style: TextStyle(
                        fontSize: 14,
                        color: priority <= 2
                            ? TriageColors.criticalRed
                            : null,
                        fontWeight:
                            priority <= 2 ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
