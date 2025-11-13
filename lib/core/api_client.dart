import 'package:dio/dio.dart';
import 'env.dart';

class ApiClient {
  ApiClient._();
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppEnv.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'content-type': 'application/json'},
    ),
  );

  // Optional: set bearer token at runtime
  static void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }
}
