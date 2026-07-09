import 'dart:async';
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
import 'package:emkf_triage_app/features/sync/domain/sync_queue_manager.dart';
import 'package:emkf_triage_app/features/triage/presentation/pages/records_page.dart';
import 'package:emkf_triage_app/injection/injection_container.dart';

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
  StreamSubscription<void>? _syncSub;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _slideController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TriageBloc>().add(LoadPendingRecords());
      _syncSub = sl<SyncQueueManager>().syncComplete.listen((_) {
        if (mounted) {
          context.read<TriageBloc>().add(LoadPendingRecords());
          _showToast(
            context,
            'Pending records synced to server',
            TriageColors.brandGreen,
            Icons.cloud_done_outlined,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _syncSub?.cancel();
    _nameController.dispose();
    _conditionController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _nameError =
          _nameController.text.trim().isEmpty ? 'Patient name is required' : null;
      _conditionError = _conditionController.text.trim().isEmpty
          ? 'Condition description is required'
          : null;
      _priorityError = _selectedPriority == null ? 'Select a priority level' : null;
    });

    if (_nameError != null ||
        _conditionError != null ||
        _priorityError != null) {
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
          context.read<TriageBloc>().add(LoadPendingRecords());
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
            backgroundColor: TriageColors.neutralBg,
            appBar: AppBar(
              title: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 26,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: TriageColors.brandRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'E',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMKF Triage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: TriageColors.neutralTextPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'Intake Form',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: TriageColors.neutralTextTertiary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.inbox_outlined,
                      size: 22,
                      color: TriageColors.neutralTextSecondary),
                  tooltip: 'View Records',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<TriageBloc>(),
                        child: const RecordsPage(),
                      ),
                    ),
                  ),
                ),
                _SyncBadge(state: state),
                const SizedBox(width: 4),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PageHeader(
                        selectedPriority: _selectedPriority,
                        selectedStatus: _selectedStatus,
                      ),
                      const SizedBox(height: 20),
                      _FormSection(
                        icon: Icons.person_outline,
                        title: 'Patient Information',
                        subtitle: 'Personal details and presenting condition',
                        children: [
                          PatientNameField(
                            controller: _nameController,
                            errorText: _nameError,
                          ),
                          const SizedBox(height: 14),
                          ConditionField(
                            controller: _conditionController,
                            errorText: _conditionError,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _FormSection(
                        icon: Icons.warning_amber_rounded,
                        title: 'Triage Assessment',
                        subtitle: 'Clinical priority and transport status',
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trip_origin,
                                size: 10,
                                color: TriageColors.neutralTextTertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Priority Level',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: TriageColors.neutralTextSecondary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
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
                          const SizedBox(height: 22),
                          Row(
                            children: [
                              Icon(
                                Icons.local_hospital,
                                size: 10,
                                color: TriageColors.neutralTextTertiary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Transport Status',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: TriageColors.neutralTextSecondary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          StatusSelector(
                            value: _selectedStatus,
                            onChanged: (value) {
                              setState(() => _selectedStatus = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _SubmitButton(
                        isSubmitting: isSubmitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 24),
                      _PendingRecordsSection(state: state),
                      const SizedBox(height: 16),
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

  void _showToast(
      BuildContext context, String message, Color color, IconData icon) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    late AnimationController animController;
    late Animation<Offset> slideAnim;
    late Animation<double> fadeAnim;

    animController = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 300),
    );
    slideAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animController,
      curve: Curves.easeOutCubic,
    ));
    fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: animController,
      curve: Curves.easeOut,
    ));

    entry = OverlayEntry(
      builder: (_) => AnimatedBuilder(
        animation: animController,
        builder: (context, child) {
          return Opacity(
            opacity: fadeAnim.value,
            child: FractionalTranslation(
              translation: slideAnim.value,
              child: child,
            ),
          );
        },
        child: Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          child: Material(
            elevation: 8,
            shadowColor: color.withAlpha(80),
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        height: 1.3,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      animController.reverse().then((_) => entry.remove());
                    },
                    child: const Icon(Icons.close, color: Colors.white60, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    animController.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) {
        animController.reverse().then((_) {
          if (entry.mounted) entry.remove();
        });
      }
    });
  }
}

class _PageHeader extends StatelessWidget {
  final int? selectedPriority;
  final TriageStatus selectedStatus;

  const _PageHeader({
    required this.selectedPriority,
    required this.selectedStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'New Triage Record',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: TriageColors.neutralTextPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Complete the patient intake form below',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: TriageColors.neutralTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _FormSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TriageColors.neutralSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TriageColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: TriageColors.brandRed.withAlpha(12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 17, color: TriageColors.brandRed),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: TriageColors.neutralTextPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: TriageColors.neutralTextTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Divider(
              color: TriageColors.neutralBorder.withAlpha(120),
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
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
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: TriageColors.brandRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: TriageColors.neutralDisabled,
          disabledForegroundColor: Colors.white60,
          elevation: 0,
          shadowColor: TriageColors.brandRed.withAlpha(60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Submitting...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18),
                  const SizedBox(width: 10),
                  const Text(
                    'Submit Triage Record',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: '${pending.length} record(s) pending sync',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: TriageColors.moderateAmberLight,
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
                color: TriageColors.moderateAmber,
              ),
              const SizedBox(width: 4),
              Text(
                '${pending.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: TriageColors.moderateAmber,
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
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: TriageColors.moderateAmber.withAlpha(20),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                Icons.cloud_upload_outlined,
                size: 16,
                color: TriageColors.moderateAmber,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Sync',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TriageColors.neutralTextPrimary,
                  ),
                ),
                Text(
                  '${records.length} record(s) waiting to be uploaded',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: TriageColors.neutralTextTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...records.take(3).map(
              (r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: TriageColors.neutralSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TriageColors.neutralBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: TriageColors.priorityBgColor(r.priority),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'P${r.priority}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: TriageColors.priorityColor(r.priority),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.patientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: TriageColors.neutralTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            r.conditionDescription,
                            style: TextStyle(
                              fontSize: 11,
                              color: TriageColors.neutralTextTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TriageColors.moderateAmberLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: TriageColors.moderateAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}


