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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(5, (i) {
          final priority = i + 1;
          final selected = value == priority;
          final color = TriageColors.priorityColor(priority);
          final bgColor = TriageColors.priorityBgColor(priority);

          return Padding(
            padding: EdgeInsets.only(bottom: i < 4 ? 8 : 0),
            child: _PriorityTile(
              priority: priority,
              label: TriageColors.priorityLabel(priority),
              description: TriageColors.priorityDescription(priority),
              color: color,
              bgColor: bgColor,
              selected: selected,
              onTap: () => onChanged(priority),
            ),
          );
        }),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 14, color: TriageColors.criticalRed),
                const SizedBox(width: 4),
                Text(
                  errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: TriageColors.criticalRed,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PriorityTile extends StatelessWidget {
  final int priority;
  final String label;
  final String description;
  final Color color;
  final Color bgColor;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityTile({
    required this.priority,
    required this.label,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? bgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : TriageColors.neutralBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _RadioIndicator(selected: selected, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? color : color.withAlpha(30),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'P$priority',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: selected ? Colors.white : color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? TriageColors.neutralTextPrimary
                                : TriageColors.neutralTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: selected
                            ? TriageColors.neutralTextSecondary
                            : TriageColors.neutralTextTertiary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle, size: 20, color: color),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool selected;
  final Color color;

  const _RadioIndicator({required this.selected, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : TriageColors.neutralDisabled,
          width: selected ? 2 : 1.5,
        ),
        color: selected ? color.withAlpha(25) : Colors.transparent,
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            )
          : null,
    );
  }
}
