import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/core/usecases/usecase.dart';
import 'package:not3s/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase extends UseCase<String, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(RegisterParams params) {
    return repository.register(params.username, params.password);
  }
}

class RegisterParams extends Equatable {
  final String username;
  final String password;

  const RegisterParams({required this.username, required this.password});

  @override
  List<Object> get props => [username, password];
}
