import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:emkf_triage_app/core/constants/app_constants.dart';
import 'package:emkf_triage_app/core/theme/triage_colors.dart';
import 'package:emkf_triage_app/features/triage/data/models/triage_record_model.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_bloc.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_event.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TriageColors.neutralBg,
      appBar: AppBar(
        title: const Text('Triage Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: () =>
                context.read<TriageBloc>().add(LoadPendingRecords()),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<TriageRecordModel>(AppConstants.triageBoxName)
            .listenable(),
        builder: (context, Box<TriageRecordModel> box, _) {
          final records = box.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: TriageColors.neutralTextTertiary),
                  const SizedBox(height: 16),
                  Text(
                    'No records yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TriageColors.neutralTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Submitted triage records will appear here',
                    style: TextStyle(
                      fontSize: 13,
                      color: TriageColors.neutralTextTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: records.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              final color = TriageColors.priorityColor(record.priority);
              final bgColor = TriageColors.priorityBgColor(record.priority);

              return Dismissible(
                key: ValueKey(record.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: TriageColors.criticalRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) {
                  box.delete(record.id);
                  context.read<TriageBloc>().add(LoadPendingRecords());
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: TriageColors.neutralSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TriageColors.neutralBorder),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'P${record.priority}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    record.patientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: TriageColors.neutralTextPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: record.synced
                                        ? TriageColors.stableGreenLight
                                        : TriageColors.moderateAmberLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    record.synced ? 'Synced' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: record.synced
                                          ? TriageColors.stableGreen
                                          : TriageColors.moderateAmber,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.conditionDescription,
                              style: TextStyle(
                                fontSize: 12,
                                color: TriageColors.neutralTextSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 12,
                                    color: TriageColors.neutralTextTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(record.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: TriageColors.neutralTextTertiary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.local_hospital,
                                    size: 12,
                                    color: TriageColors.neutralTextTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  record.status == 'pending'
                                      ? 'Pending'
                                      : 'In Transit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: TriageColors.neutralTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}
