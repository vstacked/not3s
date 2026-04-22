import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:not3s/core/error/failures.dart';
import 'package:not3s/features/auth/domain/usecases/login_usecase.dart';
import 'package:not3s/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

enum AuthMode { login, register }

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(const AuthInitial()) {
    on<AuthModeChanged>(_onModeChanged);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
  }

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;

  void _onModeChanged(AuthModeChanged event, Emitter<AuthState> emit) {
    emit(AuthInitial(mode: event.mode));
  }

  String _failureMessage(Failure failure) {
    if (failure is ServerFailure) return failure.message;
    return 'Network error. Please check your connection.';
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(mode: state.mode));
    final result = await loginUseCase(
      LoginParams(username: event.username, password: event.password),
    );
    result.fold(
      (failure) => emit(
        AuthFailure(mode: state.mode, message: _failureMessage(failure)),
      ),
      (authEntity) => emit(AuthSuccess(mode: state.mode, message: authEntity.message)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(mode: state.mode));
    final result = await registerUseCase(
      RegisterParams(username: event.username, password: event.password),
    );
    result.fold(
      (failure) => emit(
        AuthFailure(mode: state.mode, message: _failureMessage(failure)),
      ),
      (message) => emit(AuthSuccess(mode: state.mode, message: message)),
    );
  }
}
