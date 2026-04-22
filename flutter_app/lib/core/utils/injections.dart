import 'package:get_it/get_it.dart';
import 'package:not3s/core/network/auth_interceptor.dart';
import 'package:not3s/core/network/dio_network.dart';
import 'package:not3s/core/storage/storage_service.dart';
import 'package:not3s/features/auth/auth_injections.dart';
import 'package:not3s/features/notes/notes_injections.dart';
import 'package:not3s/shared/app_injections.dart';

final sl = GetIt.instance;

Future<void> initInjections() async {
  // 1. Shared (StorageService)
  await initAppInjections();

  // 2. Dio with AuthInterceptor (depends on StorageService)
  DioNetwork.initDio(
    authInterceptor: AuthInterceptor(sl<StorageService>()),
  );

  // 3. Features
  await initAuthInjections();
  await initNotesInjections();
}
