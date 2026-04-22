import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:not3s/core/storage/storage_service.dart';
import 'package:not3s/core/utils/injections.dart';

Future<void> initAppInjections() async {
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  sl.registerLazySingleton<StorageService>(
    () => StorageService(secureStorage),
  );
}
