import 'package:flutter/material.dart';
import 'package:emkf_triage_app/core/theme/triage_colors.dart';

class ConditionField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const ConditionField({
    super.key,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Condition description',
        hintText: 'Describe symptoms, vital signs, and clinical findings...',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            Icons.assignment_outlined,
            size: 20,
            color: errorText != null
                ? TriageColors.criticalRed
                : TriageColors.neutralTextTertiary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
        errorText: errorText,
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      minLines: 3,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.newline,
    );
  }
}
