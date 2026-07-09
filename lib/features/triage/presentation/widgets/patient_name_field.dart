import 'package:flutter/material.dart';

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
        labelText: 'Patient Name',
        hintText: 'Enter full name',
        prefixIcon: const Icon(Icons.person_outline),
        errorText: errorText,
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.name,
    );
  }
}
