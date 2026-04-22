part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState({AuthMode? mode}) : mode = mode ?? AuthMode.login;

  final AuthMode mode;

  @override
  List<Object?> get props => [mode];
}

class AuthInitial extends AuthState {
  const AuthInitial({super.mode});
}

class AuthLoading extends AuthState {
  const AuthLoading({super.mode});
}

class AuthSuccess extends AuthState {
  const AuthSuccess({super.mode, this.message});

  final String? message;

  @override
  List<Object?> get props => [mode, message];
}

class AuthFailure extends AuthState {
  const AuthFailure({super.mode, required this.message});

  final String message;

  @override
  List<Object?> get props => [mode, message];
}
