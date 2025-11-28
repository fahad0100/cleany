// network_exceptions.dart
import 'dart:io';

import 'package:dio/dio.dart';

import 'failure.dart';

class FailureExceptions {
  static Failure getDioException(Object error) {
    if (error is DioException) {
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
          return NetworkFailure('Request cancelled');
        default:
          return UnknownFailure('Network error occurred');
      }
    }
    switch (error) {
      case FormatException _:
        return TimeoutFailure('Connection timeout');
      case SocketException _:
        return TimeoutFailure(error.message);
      default:
        return UnknownFailure('Network error occurred');
    }
  }

  static Failure _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return NetworkFailure('Bad request');
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

