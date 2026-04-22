import 'package:not3s/features/auth/domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({required super.message, super.token});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      message: json['message'] as String,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        if (token != null) 'token': token,
      };
}
