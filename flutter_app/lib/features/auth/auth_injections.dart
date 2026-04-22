import 'package:not3s/core/network/dio_network.dart';
import 'package:not3s/core/storage/storage_service.dart';
import 'package:not3s/core/utils/injections.dart';
import 'package:not3s/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:not3s/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:not3s/features/auth/domain/repositories/auth_repository.dart';
import 'package:not3s/features/auth/domain/usecases/login_usecase.dart';
import 'package:not3s/features/auth/domain/usecases/register_usecase.dart';
import 'package:not3s/features/auth/presentation/bloc/auth_bloc.dart';

Future<void> initAuthInjections() async {
  // Data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: DioNetwork.dio),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      storageService: sl<StorageService>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));

  // BLoC — factory so each AuthPage gets a fresh instance
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
    ),
  );
}
