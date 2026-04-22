import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:not3s/core/error/exceptions.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/core/storage/storage_service.dart';
import 'package:not3s/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:not3s/features/auth/domain/entities/auth_entity.dart';
import 'package:not3s/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final StorageService storageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storageService,
  });

  @override
  Future<Either<Failure, String>> register(
    String username,
    String password,
  ) async {
    try {
      final result = await remoteDataSource.register(username, password);
      return Right(result.message);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException {
      return Left(const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
    String username,
    String password,
  ) async {
    try {
      final result = await remoteDataSource.login(username, password);
      if (result.token != null) {
        await storageService.saveToken(result.token!);
      }
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on DioException {
      return Left(const NetworkFailure());
    }
  }
}
