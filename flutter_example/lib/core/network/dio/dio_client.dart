// Configures Dio timeouts, headers, and request interceptors.
import 'package:dio/dio.dart';

import 'interceptors/auth_interceptor.dart';

/// Configures Dio timeouts, headers, and request interceptors.
Dio createDio(String baseUrl, {TokenProvider? tokenProvider}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(
      tokenProvider: tokenProvider,
      trustedOrigin: Uri.parse(baseUrl).origin,
    ),
  );
  return dio;
}
