import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String message;
  final String? token;

  const AuthEntity({required this.message, this.token});

  @override
  List<Object?> get props => [message, token];
}
