import 'package:dio/dio.dart';
import 'package:not3s/core/error/exceptions.dart';
import 'package:not3s/core/network/dio_network.dart';
import 'package:not3s/features/auth/data/models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> register(String username, String password);
  Future<AuthModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthModel> register(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {'username': username, 'password': password},
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
              'Registration failed';
      throw ServerException(message: message);
    }
  }

  @override
  Future<AuthModel> login(String username, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'username': username, 'password': password},
      );
      return AuthModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final message =
          (e.response?.data as Map<String, dynamic>?)?['error'] as String? ??
              'Login failed';
      throw ServerException(message: message);
    }
  }
}
