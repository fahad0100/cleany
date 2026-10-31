/// Fixed shared template module.
Map<String, String> networkTemplates() => {
  'lib/core/errors/error_reporter.dart': r'''
import 'dart:developer' as developer;
/// Reports unexpected technical errors without exposing them through the domain.
typedef ErrorReporter = void Function(Object error, StackTrace stackTrace);
void reportUnexpectedError(Object error, StackTrace stackTrace) {
  developer.log('Unexpected application error', name: 'app.errors',
    error: error, stackTrace: stackTrace, level: 1000);
}
''',
  'lib/core/errors/failure.dart': '''
// Domain-safe failures: no transport, framework, or database imports.
sealed class Failure {
  const Failure(this.message);
  final String message;
}
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Check your connection.']);
}
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Please sign in again.']);
}
final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid data.']);
}
final class BusinessFailure extends Failure {
  const BusinessFailure(super.message);
}
final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'The service is unavailable.']);
}
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}
''',
  'lib/core/network/failure_mapper.dart': '''
import 'package:dio/dio.dart';
import '../errors/failure.dart';

// Called only at the repository boundary. Datasources propagate exceptions.
Failure mapFailure(Object error) {
  if (error is Failure) return error;
  if (error is FormatException || error is TypeError) {
    return const ValidationFailure('Invalid server response.');
  }
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse => switch (error.response?.statusCode) {
        401 || 403 => const UnauthorizedFailure(),
        400 || 422 => const ValidationFailure(),
        409 => const BusinessFailure('The operation conflicts with existing data.'),
        _ => const ServerFailure(),
      },
      _ => const UnexpectedFailure(),
    };
  }
  return const UnexpectedFailure();
}
''',
  'lib/core/network/dio/dio_client.dart': '''
import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';

Dio createDio(String baseUrl, {TokenProvider? tokenProvider}) {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json'},
  ));
  dio.interceptors.add(AuthInterceptor(
    tokenProvider: tokenProvider,
    trustedOrigin: Uri.parse(baseUrl).origin,
  ));
  return dio;
}
''',
  'lib/core/network/dio/interceptors/auth_interceptor.dart': '''
import 'package:dio/dio.dart';

typedef TokenProvider = Future<String?> Function();

// Fetch tokens at request time. Never log credentials or embed secrets in assets.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.trustedOrigin, this.tokenProvider});
  final String trustedOrigin;
  final TokenProvider? tokenProvider;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (options.uri.origin == trustedOrigin) {
        final token = await tokenProvider?.call();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer \$token';
        }
      }
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(DioException(requestOptions: options,
        error: error, stackTrace: stackTrace));
    }
  }
}
''',
  'lib/core/network/api_endpoints.dart': '''
class ApiEndpoints {
  ApiEndpoints._();
  // Add API paths as your backend contract is defined.
}
''',
};
