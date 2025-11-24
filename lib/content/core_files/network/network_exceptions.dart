String networkExceptionsFile() {
  return '''
// network_exceptions.dart
import 'package:dio/dio.dart';

import '../errors/failure.dart';

class NetworkExceptions {
  static Failure getDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutFailure('Connection timeout');
      case DioExceptionType.sendTimeout:
        return TimeoutFailure('Send timeout');
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure('Receive timeout');
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response!.statusCode);
      case DioExceptionType.cancel:
        return CancelledFailure('Request cancelled');
      default:
        return NetworkFailure('Network error occurred');
    }
  }

  static Failure _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return OtherFailure('Bad request');
      case 401:
        return UnauthorizedFailure('Unauthorized');
      case 403:
        return UnauthorizedFailure('Forbidden');
      case 404:
        return UnauthorizedFailure('Not found');
      case 500:
        return ServerFailure('Internal server error');
      case 502:
        return ServerFailure('Bad gateway');
      default:
        return ServerFailure('Error: \$statusCode');
    }
  }
}
''';
}
