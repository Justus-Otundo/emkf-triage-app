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

class TriageFormPage extends StatefulWidget {
  const TriageFormPage({super.key});

  @override
  State<TriageFormPage> createState() => _TriageFormPageState();
}

class _TriageFormPageState extends State<TriageFormPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _conditionController = TextEditingController();

  int? _selectedPriority;
  TriageStatus _selectedStatus = TriageStatus.pending;

  String? _nameError;
  String? _conditionError;
  String? _priorityError;

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _conditionController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? 'Patient name is required' : null;
      _conditionError =
          _conditionController.text.trim().isEmpty ? 'Condition description is required' : null;
      _priorityError = _selectedPriority == null ? 'Select a priority level' : null;
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
    _slideController.reset();
    _slideController.forward();
    context.read<TriageBloc>().add(ResetTriageForm());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TriageBloc, TriageState>(
      listener: (context, state) {
        if (state is TriageSaved) {
          _showToast(
            context,
            state.syncedToServer
                ? 'Record submitted and synced'
                : 'Saved offline — will sync when connected',
            state.syncedToServer
                ? TriageColors.brandGreen
                : TriageColors.moderateAmber,
            Icons.check_circle_outline,
          );
          _resetForm();
        }
        if (state is TriageError) {
          _showToast(
            context,
            state.failure.message,
            TriageColors.criticalRed,
            Icons.error_outline,
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is TriageSubmitting;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: TriageColors.scaffoldBg,
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Triage Intake',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                _SyncBadge(state: state),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderSection(
                        selectedPriority: _selectedPriority,
                        selectedStatus: _selectedStatus,
                        name: _nameController.text,
                        condition: _conditionController.text,
                      ),
                      const SizedBox(height: 20),
                      _SectionCard(
                        icon: Icons.person_outline,
                        title: 'Patient Details',
                        children: [
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
                      const SizedBox(height: 12),
                      _SectionCard(
                        icon: Icons.warning_amber_rounded,
                        title: 'Triage Assessment',
                        children: [
                          const Text(
                            'Priority Level',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          PrioritySelector(
                            value: _selectedPriority,
                            errorText: _priorityError,
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value;
                                _priorityError = null;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Transport Status',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          StatusSelector(
                            value: _selectedStatus,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedStatus = value);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SubmitButton(
                        isSubmitting: isSubmitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 24),
                      _PendingRecordsSection(state: state),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showToast(BuildContext context, String message, Color color, IconData icon) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 80,
        left: 16,
        right: 16,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => entry.remove(),
                  child: const Icon(Icons.close, color: Colors.white70, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: TriageColors.brandRed),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final int? selectedPriority;
  final TriageStatus selectedStatus;
  final String name;
  final String condition;

  const _HeaderSection({
    required this.selectedPriority,
    required this.selectedStatus,
    required this.name,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPriority == null) return const SizedBox.shrink();

    final isCritical = selectedPriority! <= 2;
    final color = TriageColors.priorityColor(selectedPriority!);
    final bgColor = TriageColors.priorityBgColor(selectedPriority!);
    final label = selectedPriority == 1
        ? 'CRITICAL — Immediate attention required'
        : selectedPriority == 2
            ? 'EMERGENCY — High priority case'
            : 'Priority $selectedPriority — Stable condition';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: color.withAlpha(120), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCritical ? Icons.error_outline : Icons.check_circle_outline,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (name.isNotEmpty)
                  Text(
                    name,
                    style: TextStyle(
                      color: color.withAlpha(200),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: selectedStatus == TriageStatus.pending
                  ? Colors.orange.shade100
                  : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              selectedStatus == TriageStatus.pending ? 'Pending' : 'In-Transit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selectedStatus == TriageStatus.pending
                    ? Colors.orange.shade800
                    : Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isSubmitting, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isSubmitting ? null : onPressed,
        icon: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded, size: 20),
        label: Text(
          isSubmitting ? 'Submitting...' : 'Submit Triage Record',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: TriageColors.brandRed,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: TriageColors.brandRed.withAlpha(80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final TriageState state;

  const _SyncBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is! TriageRecordsLoaded) return const SizedBox.shrink();
    final pending = (state as TriageRecordsLoaded).pendingRecords;
    if (pending.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: '${pending.length} record(s) pending sync',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: TriageColors.moderateAmber.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: TriageColors.moderateAmber.withAlpha(80),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 14,
                color: Colors.amber.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                '${pending.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingRecordsSection extends StatelessWidget {
  final TriageState state;

  const _PendingRecordsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is! TriageRecordsLoaded) return const SizedBox.shrink();
    final records = (state as TriageRecordsLoaded).pendingRecords;
    if (records.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              'Pending Sync',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...records.take(3).map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: TriageColors.priorityColor(r.priority),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            r.conditionDescription,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.cloud_outlined,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
