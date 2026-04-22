import 'package:dartz/dartz.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/features/auth/domain/entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> register(String username, String password);
  Future<Either<Failure, AuthEntity>> login(String username, String password);
}
