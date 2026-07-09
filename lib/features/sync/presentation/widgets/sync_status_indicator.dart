import 'dart:async';
import 'package:flutter/material.dart';
import 'package:emkf_triage_app/features/sync/domain/sync_service.dart';

class SyncStatusIndicator extends StatefulWidget {
  final SyncService syncService;

  const SyncStatusIndicator({super.key, required this.syncService});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  SyncStatus _status = SyncStatus.idle;
  StreamSubscription<SyncStatus>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.syncService.statusStream.listen((status) {
      if (mounted) {
        setState(() => _status = status);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (_status) {
      SyncStatus.connected => (
        Icons.cloud_done,
        Colors.green,
        'Connected',
      ),
      SyncStatus.disconnected => (
        Icons.cloud_off,
        Colors.red.shade400,
        'Offline',
      ),
      SyncStatus.syncing => (
        Icons.sync,
        Colors.orange,
        'Syncing...',
      ),
      SyncStatus.idle => (
        Icons.cloud_outlined,
        Colors.grey,
        'Ready',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
