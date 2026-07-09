import 'package:flutter/material.dart';

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
        labelText: 'Condition Description',
        hintText: 'Describe the patient\'s condition...',
        prefixIcon: const Icon(Icons.medical_services_outlined),
        errorText: errorText,
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.newline,
    );
  }
}
