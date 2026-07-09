import 'package:flutter/material.dart';
import 'package:emkf_triage_app/core/theme/triage_colors.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';

class StatusSelector extends StatelessWidget {
  final TriageStatus value;
  final ValueChanged<TriageStatus> onChanged;

  const StatusSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TriageColors.neutralBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: TriageColors.neutralBorder),
      ),
      child: Row(
        children: [
          _StatusOption(
            status: TriageStatus.pending,
            label: 'Pending',
            icon: Icons.hourglass_bottom,
            selected: value == TriageStatus.pending,
            selectedColor: TriageColors.moderateAmber,
            onTap: () => onChanged(TriageStatus.pending),
          ),
          const SizedBox(width: 4),
          _StatusOption(
            status: TriageStatus.inTransit,
            label: 'In Transit',
            icon: Icons.local_hospital,
            selected: value == TriageStatus.inTransit,
            selectedColor: TriageColors.brandGreen,
            onTap: () => onChanged(TriageStatus.inTransit),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final TriageStatus status;
  final String label;
  final IconData icon;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.label,
    required this.icon,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(12),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? selectedColor
                      : TriageColors.neutralTextTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? TriageColors.neutralTextPrimary
                        : TriageColors.neutralTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
