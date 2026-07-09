import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emkf_triage_app/core/network/api_client.dart';
import 'package:emkf_triage_app/core/network/network_info.dart';
import 'package:emkf_triage_app/features/sync/data/datasources/sync_queue_datasource.dart';
import 'package:emkf_triage_app/features/sync/domain/sync_queue_manager.dart';
import 'package:emkf_triage_app/features/sync/domain/sync_service.dart';
import 'package:emkf_triage_app/features/triage/data/datasources/triage_local_datasource.dart';
import 'package:emkf_triage_app/features/triage/data/datasources/triage_remote_datasource.dart';
import 'package:emkf_triage_app/features/triage/data/repositories/triage_repository_impl.dart';
import 'package:emkf_triage_app/features/triage/domain/repositories/triage_repository.dart';
import 'package:emkf_triage_app/features/triage/presentation/bloc/triage_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  sl.registerLazySingleton<TriageLocalDatasource>(
    () => TriageLocalDatasourceImpl(),
  );

  sl.registerLazySingleton<TriageRemoteDatasource>(
    () => TriageRemoteDatasourceMock(),
  );

  sl.registerLazySingleton<TriageRepository>(
    () => TriageRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<SyncQueueDatasource>(
    () => SyncQueueDatasourceImpl(),
  );

  sl.registerLazySingleton<SyncService>(
    () => SyncService(
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<SyncQueueManager>(
    () => SyncQueueManager(
      queue: sl(),
      remoteDatasource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerFactory<TriageBloc>(
    () => TriageBloc(repository: sl()),
  );
}
