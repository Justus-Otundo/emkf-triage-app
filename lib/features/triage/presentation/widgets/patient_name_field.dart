import 'package:flutter/material.dart';
import 'package:emkf_triage_app/core/theme/triage_colors.dart';

class PatientNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const PatientNameField({
    super.key,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Patient name',
        hintText: 'Enter full name',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(
            Icons.person_outline,
            size: 20,
            color: errorText != null
                ? TriageColors.criticalRed
                : TriageColors.neutralTextTertiary,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
        errorText: errorText,
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
    );
  }
}
