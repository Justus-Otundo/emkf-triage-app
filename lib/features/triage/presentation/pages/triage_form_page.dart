import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:emkf_triage_app/core/theme/triage_colors.dart';
import 'package:emkf_triage_app/features/triage/domain/entities/triage_record.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_bloc.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_event.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_state.dart';
import 'package:emkf_triage_app/features/triage/presentation/widgets/condition_field.dart';
import 'package:emkf_triage_app/features/triage/presentation/widgets/patient_name_field.dart';
import 'package:emkf_triage_app/features/triage/presentation/widgets/priority_dropdown.dart';
import 'package:emkf_triage_app/features/triage/presentation/widgets/status_selector.dart';
import 'package:emkf_triage_app/features/triage/presentation/widgets/triage_status_banner.dart';

class TriageFormPage extends StatefulWidget {
  const TriageFormPage({super.key});

  @override
  State<TriageFormPage> createState() => _TriageFormPageState();
}

class _TriageFormPageState extends State<TriageFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _conditionController = TextEditingController();

  int? _selectedPriority;
  TriageStatus _selectedStatus = TriageStatus.pending;

  String? _nameError;
  String? _conditionError;
  String? _priorityError;

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Required' : null;
      _conditionError =
          _conditionController.text.trim().isEmpty ? 'Required' : null;
      _priorityError = _selectedPriority == null ? 'Required' : null;
    });

    if (_nameError != null || _conditionError != null || _priorityError != null) {
      return;
    }

    context.read<TriageBloc>().add(SubmitTriage(
          patientName: _nameController.text,
          conditionDescription: _conditionController.text,
          priority: _selectedPriority!,
          status: _selectedStatus,
        ));
  }

  void _resetForm() {
    _nameController.clear();
    _conditionController.clear();
    setState(() {
      _selectedPriority = null;
      _selectedStatus = TriageStatus.pending;
      _nameError = null;
      _conditionError = null;
      _priorityError = null;
    });
    context.read<TriageBloc>().add(ResetTriageForm());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TriageBloc, TriageState>(
      listener: (context, state) {
        if (state is TriageSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.syncedToServer
                  ? 'Record submitted and synced'
                  : 'Record saved offline — will sync when connected'),
              backgroundColor: state.syncedToServer
                  ? TriageColors.stableGreen
                  : TriageColors.moderateAmber,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
          _resetForm();
        }
        if (state is TriageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: TriageColors.criticalRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is TriageSubmitting;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  const Text('EMKF Triage'),
                ],
              ),
              actions: [
                if (state is TriageRecordsLoaded && state.pendingRecords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.pendingRecords.length} pending',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedPriority != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TriageStatusBanner(
                          record: TriageRecord(
                            id: '',
                            patientName: _nameController.text,
                            conditionDescription: _conditionController.text,
                            priority: _selectedPriority!,
                            status: _selectedStatus,
                          ),
                        ),
                      ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Patient Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            PatientNameField(
                              controller: _nameController,
                              errorText: _nameError,
                            ),
                            const SizedBox(height: 16),
                            ConditionField(
                              controller: _conditionController,
                              errorText: _conditionError,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Triage Assessment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            PriorityDropdown(
                              value: _selectedPriority,
                              errorText: _priorityError,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value;
                                  _priorityError = null;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            StatusSelector(
                              value: _selectedStatus,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting ? null : _submit,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(
                          isSubmitting ? 'Submitting...' : 'Submit Triage Record',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TriageColors.brandRed,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
