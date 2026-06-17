import 'package:dio/dio.dart';

// cliente http centralizado - uma instância só para todo o app
class ApiClient {
  static final ApiClient instance = ApiClient._init();
  late final Dio dio;

  ApiClient._init() {
    dio = Dio(BaseOptions(
      // api pública de citações
      baseUrl: 'https://zenquotes.io/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {
        'X-Content-Type-Options': 'nosniff',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (!options.uri.scheme.startsWith('https')) {
          handler.reject(
            DioException(
              requestOptions: options,
              message: 'Apenas conexões HTTPS são permitidas.',
            ),
          );
          return;
        }
        handler.next(options);
      },
    ));
  }

  // máximo 2 tentativas antes de lançar o erro para o chamador usar cache
  Future<Response<T>> getWithRetry<T>(String path, {int maxRetries = 2}) async {
    DioException? lastError;
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await dio.get<T>(path);
      } on DioException catch (e) {
        lastError = e;
      }
    }
    throw lastError!;
  }
}
