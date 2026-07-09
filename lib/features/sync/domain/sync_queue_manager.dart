import 'dart:async';
import 'package:emkf_triage_app/core/constants/app_constants.dart';
import 'package:emkf_triage_app/core/network/network_info.dart';
import 'package:emkf_triage_app/features/sync/data/datasources/sync_queue_datasource.dart';
import 'package:emkf_triage_app/features/triage/data/datasources/triage_remote_datasource.dart';
import 'package:emkf_triage_app/features/triage/data/models/triage_record_model.dart';

class SyncQueueManager {
  final SyncQueueDatasource _queue;
  final TriageRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  StreamSubscription<bool>? _connectivitySub;
  bool _isSyncing = false;
  Timer? _retryTimer;

  final StreamController<void> _syncCompleteController =
      StreamController<void>.broadcast();
  Stream<void> get syncComplete => _syncCompleteController.stream;

  SyncQueueManager({
    required SyncQueueDatasource queue,
    required TriageRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _queue = queue,
        _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  void startListening() {
    _connectivitySub = _networkInfo.onConnectivityChanged.listen(
      (isConnected) {
        if (isConnected && !_isSyncing) {
          _processQueue();
        }
      },
    );

    _retryTimer = Timer.periodic(
      AppConstants.syncRetryInterval,
      (_) async {
        if (await _networkInfo.isConnected && !_isSyncing) {
          _processQueue();
        }
      },
    );
  }

  void stopListening() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _syncCompleteController.close();
  }

  Future<void> _processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _queue.getPending();
      if (pending.isEmpty) {
        return;
      }

      for (final record in pending) {
        try {
          await _remoteDatasource.submitRecord(record);
          final updated = TriageRecordModel(
            id: record.id,
            patientName: record.patientName,
            conditionDescription: record.conditionDescription,
            priority: record.priority,
            status: record.status,
            createdAt: record.createdAt,
            synced: true,
          );
          await _queue.enqueue(updated);
        } catch (_) {
          break;
        }
      }

      _syncCompleteController.add(null);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> processNow() async {
    if (await _networkInfo.isConnected) {
      await _processQueue();
    }
  }
}
