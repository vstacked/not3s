part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthModeChanged extends AuthEvent {
  const AuthModeChanged({required this.mode});

  final AuthMode mode;

  @override
  List<Object> get props => [mode];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object> get props => [username, password];
}
