import 'package:dio/dio.dart';
import 'package:not3s/core/network/auth_interceptor.dart';

class DioNetwork {
  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio({AuthInterceptor? authInterceptor}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://not3s.onrender.com/api',
        ),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (authInterceptor != null) {
      dio.interceptors.add(authInterceptor);
    }

    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );

    return dio;
  }

  static void initDio({AuthInterceptor? authInterceptor}) {
    _dio = _createDio(authInterceptor: authInterceptor);
  }
}
