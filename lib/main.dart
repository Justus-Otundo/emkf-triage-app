import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:emkf_triage_app/app.dart';
import 'package:emkf_triage_app/core/constants/app_constants.dart';
import 'package:emkf_triage_app/features/triage/data/models/triage_record_model.dart';
import 'package:emkf_triage_app/features/sync/domain/sync_queue_manager.dart';
import 'package:emkf_triage_app/injection/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TriageRecordModelAdapter());

  await Hive.openBox<TriageRecordModel>(AppConstants.triageBoxName);

  await initDependencies();

  final syncManager = sl<SyncQueueManager>();
  syncManager.startListening();

  AppLifecycleListener(
    onResume: () => syncManager.processNow(),
  );

  runApp(const TriageApp());
}
