import 'dart:async';
import 'package:emkf_triage_app/core/network/network_info.dart';

class SyncService {
  final NetworkInfo _networkInfo;

  StreamSubscription<bool>? _connectivitySub;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  SyncService({
    required NetworkInfo networkInfo,
  }) : _networkInfo = networkInfo;

  Stream<SyncStatus> get statusStream => _statusController.stream;

  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  void startMonitoring() {
    _connectivitySub = _networkInfo.onConnectivityChanged.listen(
      (isConnected) {
        if (isConnected) {
          _statusController.add(SyncStatus.connected);
        } else {
          _statusController.add(SyncStatus.disconnected);
        }
      },
    );

    _networkInfo.isConnected.then((connected) {
      _statusController.add(
        connected ? SyncStatus.connected : SyncStatus.disconnected,
      );
    });
  }

  void stopMonitoring() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  void updatePendingCount(int count) {
    _pendingCount = count;
  }

  void dispose() {
    stopMonitoring();
    _statusController.close();
  }
}

enum SyncStatus { connected, disconnected, syncing, idle }
