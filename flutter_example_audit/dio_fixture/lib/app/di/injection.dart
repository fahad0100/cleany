// Registers application-scoped services and factory presentation controllers.
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../../core/network/dio/dio_client.dart';

import 'package:test_cleany_dio/features/probe/data/datasources/probe_remote_data_source.dart';
import 'package:test_cleany_dio/features/probe/data/repositories/probe_repository_impl.dart';
import 'package:test_cleany_dio/features/probe/domain/repositories/probe_repository.dart';
import 'package:test_cleany_dio/features/probe/domain/usecases/get_probe.dart';
import 'package:test_cleany_dio/features/probe/presentation/bloc/probe_bloc.dart';

// One composition root. Application services live in an explicit app scope.
// Repositories are lazy singletons; presentation controllers are factories.
/// Registers application-scoped services and factory presentation controllers.
Future<void> configureDependencies(GetIt container, AppConfig config) async {
  container.pushNewScope(scopeName: 'app');
  try {
    container.registerSingleton<AppConfig>(config);
    container.registerLazySingleton<Dio>(
      () => createDio(config.apiBaseUrl),
      dispose: (dio) => dio.close(force: true),
    );
    registerFeatureDependencies(container);
  } catch (_) {
    await container.popScope();
    rethrow;
  }
}

/// Registers application-scoped services and factory presentation controllers.
void registerFeatureDependencies(GetIt container) {
  container.registerLazySingleton<ProbeRemoteDataSource>(
    () => ProbeRemoteDataSource(container<Dio>()),
  );
  container.registerLazySingleton<ProbeRepository>(
    () => ProbeRepositoryImpl(container<ProbeRemoteDataSource>()),
  );
  container.registerLazySingleton<GetProbe>(
    () => GetProbe(container<ProbeRepository>()),
  );

  container.registerFactory<ProbeBloc>(() => ProbeBloc(container<GetProbe>()));
}

/// Registers application-scoped services and factory presentation controllers.
Future<void> disposeDependencies(GetIt container) => container.popScope();
