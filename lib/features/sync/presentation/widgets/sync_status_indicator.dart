import 'dart:async';
import 'package:flutter/material.dart';
import 'package:emkf_triage_app/features/sync/domain/sync_service.dart';

class SyncStatusIndicator extends StatefulWidget {
  final SyncService syncService;

  const SyncStatusIndicator({super.key, required this.syncService});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  SyncStatus _status = SyncStatus.idle;
  StreamSubscription<SyncStatus>? _sub;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _sub = widget.syncService.statusStream.listen((status) {
      if (mounted) setState(() => _status = status);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color, label, animating) = switch (_status) {
      SyncStatus.connected => (
        Icons.cloud_done,
        const Color(0xFF00A859),
        'Connected',
        false,
      ),
      SyncStatus.disconnected => (
        Icons.cloud_off,
        const Color(0xFFCC0000),
        'Offline',
        false,
      ),
      SyncStatus.syncing => (
        Icons.sync,
        const Color(0xFFFFA000),
        'Syncing...',
        true,
      ),
      SyncStatus.idle => (
        Icons.cloud_outlined,
        Colors.grey,
        'Ready',
        false,
      ),
    };

    if (animating) {
      _pulseController.repeat();
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, child) {
        final scale = animating ? 1.0 + (_pulseController.value * 0.15) : 1.0;
        final opacity = animating
            ? 0.6 + (_pulseController.value * 0.4)
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
