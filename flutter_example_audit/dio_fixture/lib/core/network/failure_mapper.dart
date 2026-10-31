// Maps technical exceptions to Failure values at the repository boundary.
import 'package:dio/dio.dart';

import '../errors/failure.dart';

// Called only at the repository boundary. Datasources propagate exceptions.
/// Maps technical exceptions to Failure values at the repository boundary.
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
        409 => const BusinessFailure(
          'The operation conflicts with existing data.',
        ),
        _ => const ServerFailure(),
      },
      _ => const UnexpectedFailure(),
    };
  }
  return const UnexpectedFailure();
}
