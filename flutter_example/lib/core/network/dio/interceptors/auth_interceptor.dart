// Adds a session token only to requests for the trusted API origin.
import 'package:dio/dio.dart';

/// Adds a session token only to requests for the trusted API origin.
typedef TokenProvider = Future<String?> Function();

// Fetch tokens at request time. Never log credentials or embed secrets in assets.
/// Adds a session token only to requests for the trusted API origin.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.trustedOrigin, this.tokenProvider});
  final String trustedOrigin;
  final TokenProvider? tokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (options.uri.origin == trustedOrigin) {
        final token = await tokenProvider?.call();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
