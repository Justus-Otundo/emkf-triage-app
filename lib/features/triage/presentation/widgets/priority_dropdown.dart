import 'package:flutter/material.dart';
import 'package:emkf_triage_app/core/theme/triage_colors.dart';

class PrioritySelector extends StatelessWidget {
  final int? value;
  final String? errorText;
  final ValueChanged<int> onChanged;

  const PrioritySelector({
    super.key,
    required this.value,
    this.errorText,
    required this.onChanged,
  });

  static const _labels = {
    1: 'Critical',
    2: 'Emergency',
    3: 'Urgent',
    4: 'Semi-Urgent',
    5: 'Non-Urgent',
  };

  static const _subLabels = {
    1: 'Life-threatening',
    2: 'High risk',
    3: 'Moderate',
    4: 'Stable',
    5: 'Minor',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(5, (i) {
            final priority = i + 1;
            final selected = value == priority;
            final color = TriageColors.priorityColor(priority);

            return GestureDetector(
              onTap: () => onChanged(priority),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: (MediaQuery.of(context).size.width - 56) / 5,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? color : color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? color : color.withAlpha(60),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$priority',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _labels[priority]!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        if (value != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _subLabels[value]!,
              style: TextStyle(
                fontSize: 13,
                color: TriageColors.priorityColor(value!),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: TextStyle(
                fontSize: 12,
                color: TriageColors.criticalRed,
              ),
            ),
          ),
      ],
    );
  }
}
