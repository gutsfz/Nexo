import 'package:dio/dio.dart';

// cliente http centralizado - uma instância só para todo o app
class ApiClient {
  static final ApiClient instance = ApiClient._init();
  late final Dio dio;

  ApiClient._init() {
    dio = Dio(BaseOptions(
      // api pública de citações
      baseUrl: 'https://api.quotable.io',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }
}